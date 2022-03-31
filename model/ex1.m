% This datastore points to the "clean" speech files
adsSpeech = audioDatastore("../datasets_fullband/clean_fullband",IncludesubFolders=true);
% This datastore points to the noise files
adsNoise = audioDatastore("../datasets_fullband/noise_fullband",IncludesubFolders=true);

% This transform datastore returns pairs (clean/noise) STFT
tds = transform(adsSpeech,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));

% Params for model layers
numFeatures = 257;
FFTLength = 512;
win_length = 512;
overlap_length = 512-256;
numHiddenUnits_fb = 512;
numHiddenUnits_sb = 384;
numSegments = 8;

% Construct model layers
lgraph = layerGraph();
tempLayers = [
    sequenceInputLayer([numFeatures,311],"Name","sequence_1")
    padLayer("Name","padLayer_1")
    ];
lgraph = addLayers(lgraph,tempLayers);

% RHS
tempLayers= unfoldLayer("Name","unfold_1");
lgraph = addLayers(lgraph,tempLayers);

%LHS
tempLayers = [
    normLayer(false,"Name","norm_1") %SBT
    % permuteLayer(false,[1,3,2,4],"Name","permute_1")
    % !
    lstmLayer(numHiddenUnits_fb,"Name","lstm_1")
    lstmLayer(numHiddenUnits_fb, "Name","lstm_2")
    fullyConnectedLayer(numFeatures,"Name","fc_1")
    reluLayer("Name","relu")
    % permuteLayer(false,[1,2,3,4],"Name","permute_2")
    unsqueezeLayer(2,"Name","unsqueeze_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(2,2,"Name","concat")
    % 257    32     1   313  'SCBT'
    normLayer(true, "Name","norm_3") % output is 257 313 32 "BTC" but...
    checkdimsLayer("Name","checkdim1")
    % flattenLayer()
    
    % 32     1   313  'CBT'
    % lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
    % lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
    % 384     1   313  'CBT'
    sequenceFoldingLayer("Name","seqfold") ];
lgraph = addLayers(lgraph,tempLayers);
    tempLayers = [relabelLayer('CBT', "Name","relabel_1")
        checkdimsLayer("Name","checkdim5")
        lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
        lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
        checkdimsLayer("Name","checkdim6")
        fullyConnectedLayer(2,"Name","fc_2")
        relabelLayer('CBU', "Name","relabel_2")
        checkdimsLayer("Name","checkdim3")];
lgraph = addLayers(lgraph,tempLayers);
    tempLayers = [
    sequenceUnfoldingLayer("Name","sequnfold")
    checkdimsLayer("Name","checkdim4")
    finalLayer()
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
    

% clean up helper variable
clear tempLayers;
lgraph = connectLayers(lgraph,"padLayer_1","norm_1");
lgraph = connectLayers(lgraph,"padLayer_1","unfold_1");
lgraph = connectLayers(lgraph,"unfold_1","concat/in2");
lgraph = connectLayers(lgraph,"unsqueeze_1","concat/in1");
lgraph = connectLayers(lgraph,"seqfold/out","relabel_1");
lgraph = connectLayers(lgraph,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
lgraph = connectLayers(lgraph,"checkdim3","sequnfold/in");

% training options
miniBatchSize = 48;
options = trainingOptions("adam", ...
    MaxEpochs=3, ...
    InitialLearnRate=0.001,...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.9, ...
    LearnRateDropPeriod=1);

% train the model
denoiseNetFullyConnected = trainNetwork(tds,lgraph,options);