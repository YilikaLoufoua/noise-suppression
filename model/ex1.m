% This datastore points to the "clean" speech files
adsSpeech = audioDatastore("../datasets_fullband/clean_fullband",IncludesubFolders=true);
% This datastore points to the noise files
adsNoise = audioDatastore("../datasets_fullband/noise_fullband",IncludesubFolders=true);

% This transform datastore returns pairs (clean/noise) STFT
tds = transform(adsSpeech,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));

numFeatures = 257;
FFTLength = 512;
win_length = 512;
overlap_length = 512-256;
numHiddenUnits_fb = 512;
numHiddenUnits_sb = 384;
numSegments = 8;

lgraph = layerGraph();
tempLayers = sequenceInputLayer([numFeatures,numSegments],"Name","sequence_1");
lgraph = addLayers(lgraph,tempLayers);

tempLayers= reshapeLayer(false,"Name","reshape_1");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    normLayer("Name","norm_1")
    flattenLayer("Name","flatten")
    lstmLayer(numHiddenUnits_fb,"Name","lstm_1")
    lstmLayer(numHiddenUnits_fb,"Name","lstm_2")
    fullyConnectedLayer(numFeatures,"Name","fc_1")
    reluLayer("Name","relu")
    reshapeLayer(true, "Name","reshape_2")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    % concatLayer("InputNames", {'in1'  'in2'})
    concatenationLayer(2,2,"Name","concat")
    normLayer("Name","norm_2")
    flattenLayer("Name","flatten_2")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
    fullyConnectedLayer(numFeatures,"Name","fc_2")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);

% clean up helper variable
clear tempLayers;
lgraph = connectLayers(lgraph,"sequence_1","norm_1");
lgraph = connectLayers(lgraph,"sequence_1","reshape_1");
lgraph = connectLayers(lgraph,"reshape_1","concat/in2");
lgraph = connectLayers(lgraph,"reshape_2","concat/in1");


miniBatchSize = 128;
options = trainingOptions("adam", ...
    MaxEpochs=3, ...
    InitialLearnRate=1e-5,...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.9, ...
    LearnRateDropPeriod=1);

denoiseNetFullyConnected = trainNetwork(tds,lgraph,options);
