% This datastore points to the "clean" speech files
adsSpeech = audioDatastore("../../../datasets_fullband/clean_fullband",IncludesubFolders=true,LabelSource="foldernames");
% This datastore points to the noise files
adsNoise = audioDatastore("../../../datasets_fullband/noise_fullband",IncludesubFolders=true);

% This transform datastore returns pairs (clean/noise) STFT
% tds = transform(adsSpeech,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));
% Split the speech dataset into training, validation, and test sets
[adsTrain,adsVal,adsTest] = splitEachLabel(adsSpeech,0.95,0.025);

% This transform datastore returns pairs (clean/noise) STFT
tds = transform(adsTrain,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));
adsVal = transform(adsVal,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));
adsTest = transform(adsTest,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));



% Params for model layers
numFeatures = 257;
FFTLength = 512;
win_length = 512;
overlap_length = 512-256;
numHiddenUnits_fb = 512;
numHiddenUnits_sb = 384;
numSegments = 8;
time = importdata("variable.txt");

% Construct model layers
lgraph = layerGraph();
tempLayers = [
    sequenceInputLayer([numFeatures,time],"Name","sequence_1") 
    % [5, 1, 257, 92]
    padLayer("Name","padLayer_1")
    % [5, 1, 257, 94]  [257,5,94] 'SBT'
    ];
lgraph = addLayers(lgraph,tempLayers);

% RHS
tempLayers= [
    % % [5, 1, 257, 94]  [257,5,94] 'SBT'
    unfoldLayer("Name","unfold_1")]; 
% [5, 257, 1, 31, 94]
% [5, 257, 31, 94]  [257, 31, 5, 94] 'SCBT'
lgraph = addLayers(lgraph,tempLayers);

%LHS
tempLayers = [
    normLayer(false, "Name","norm_1") 
    % [5, 1, 257, 94]  [257,5,94] 'SBT'
    lstmLayer(numHiddenUnits_fb,"Name","lstm_1")
    lstmLayer(numHiddenUnits_fb, "Name","lstm_2")
    % [5, 94, 512]  [512,5,94]  'CBT'
    fullyConnectedLayer(numFeatures,"Name","fc_1")
    % [,,]  [257,5,94]  'CBT'
    reluLayer("Name","relu")
    % [,,]  [257,5,94]  'CBT'
    unsqueezeLayer(2,"Name","unsqueeze_1")
    % [5, 1, 257, 94]
    % [5, 257, 1, 1, 94]
    % [5, 257, 1, 94]  [257,1,5,94] 'SCBT'
    ];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(2,2,"Name","concat")
    % [5, 257, 32, 94]  [257, 32, 5, 94] 'SCBT'
    % checkdimsLayer("Name","cd1")
    % layerNormalizationLayer("Name","norm_2")
    normLayer(true, "Name","norm_3") 
    % [,,]   [32, 1285, 94] "CTU"
    relabelLayer(time+2, 'CBT', "Name","relabel_1")
    % [1285, 32, 94]  [32, 1285, 94]  'CBT'
    lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
    % [1285, 94, 384]  [384, 1285, 94]  'CBT'
    fullyConnectedLayer(2,"Name","fc_2")
    % [1285, 2, 94]  [2,1285, 94]  'CBT'
    finalLayer(time+2)
    % [5, 2, 257, 92] [257, 92, 2, 5]  'SSCB'
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
    

% clean up helper variable
clear tempLayers;
lgraph = connectLayers(lgraph,"padLayer_1","norm_1");
lgraph = connectLayers(lgraph,"padLayer_1","unfold_1");
lgraph = connectLayers(lgraph,"unfold_1","concat/in2");
lgraph = connectLayers(lgraph,"unsqueeze_1","concat/in1");

analyzeNetwork(lgraph);

% training options
    % ValidationData=adsVal, ...
    % ValidationPatience=5, ...
miniBatchSize = 5;
options = trainingOptions("adam", ...
    MaxEpochs=4, ...
    InitialLearnRate=0.0001,...
    MiniBatchSize=miniBatchSize, ...
    ValidationData=adsVal, ...
    ValidationPatience=5, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    GradientDecayFactor=0.9,...
    SquaredGradientDecayFactor=0.999);

% train the model
% load("refactor_init.mat");
denoiseNetFullyConnected = trainNetwork(tds,lgraph,options);
