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
tempLayers = [sequenceInputLayer([numFeatures,numSegments],"Name","sequence_1")
                normLayer("Name","norm_1")];
lgraph = addLayers(lgraph,tempLayers);

% RHS
tempLayers= reshapeLayer(false,"Name","reshape_1");
lgraph = addLayers(lgraph,tempLayers);

%LHS
tempLayers = [
    flattenLayer("Name","flatten")
    lstmLayer(numHiddenUnits_fb,"Name","lstm_1")
    lstmLayer(numHiddenUnits_fb,"Name","lstm_2")
    fullyConnectedLayer(numFeatures,"Name","fc_1")
    reluLayer("Name","relu")
    reshapeLayer(true, "Name","reshape_2")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(2,2,"Name","concat")
    normLayer("Name","norm_3")
    flattenLayer("Name","flatten_2")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
    fullyConnectedLayer(numFeatures,"Name","fc_2")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);

% clean up helper variable
clear tempLayers;
lgraph = connectLayers(lgraph,"norm_1","reshape_1");
lgraph = connectLayers(lgraph,"norm_1","flatten");
lgraph = connectLayers(lgraph,"reshape_1","concat/in2");
lgraph = connectLayers(lgraph,"reshape_2","concat/in1");

% training options
miniBatchSize = 128;
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
