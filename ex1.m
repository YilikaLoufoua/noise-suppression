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
    lstmLayer(numHiddenUnits_fb,"Name","lstm_1")
    lstmLayer(numHiddenUnits_fb, "Name","lstm_2")
    
    fullyConnectedLayer(numFeatures,"Name","fc_1")
    reluLayer("Name","relu")
    unsqueezeLayer(2,"Name","unsqueeze_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(2,2,"Name","concat")
    % 257    32     1   313  'SCBT'
    normLayer(true, "Name","norm_3") % output is 257 313 32 "BTC" but...
    % 32   257   313 'CTU'
    % 32   5140  313  'CTU'
    sequenceFoldingLayer("Name","seqfold") ];
lgraph = addLayers(lgraph,tempLayers);
    tempLayers = [
        % 32   257   313  'CBU'
        % 32   1608820 'CB'
        relabelLayer(true,'CBT', "Name","relabel_1")
        % 32   257   313  'CBT'
        % 32   5140  313  'CBT'
        lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
        lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
        % 384   257   313 'CBT'
        % 384   5140  313 'CBT'
        % checkdimsLayer("Name", "check_1")
        fullyConnectedLayer(1,"Name","fc_2")
        % 1   257   313  'CBT'
        % 1   5140  313  'CBT'
        relabelLayer(false,'CB', "Name","relabel_2")];
lgraph = addLayers(lgraph,tempLayers);
    tempLayers = [
    sequenceUnfoldingLayer("Name","sequnfold")
    % 1     1   257   313  'CBTU'
    % 1     5140  313      'CBT'
    finalLayer()
    % 257   311     1     1   'SSCB'
    % 257   311     1    20   'SSCB'
    checkdimsLayer("Name", "check_2")
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
lgraph = connectLayers(lgraph,"relabel_2","sequnfold/in");

% training options
miniBatchSize = 20;
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