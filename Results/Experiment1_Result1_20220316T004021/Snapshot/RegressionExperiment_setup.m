function [adsTrain, adsVal, layers, options] = RegressionExperiment_setup(params)

%% Import datasets
% Import clean audio dataset
dataFolder = "datasets_fullband/clean_fullband";
adsClean = audioDatastore(fullfile(dataFolder), 'LabelSource', 'foldernames');

% Import noise dataset
noiseFolder = "datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

%% Data preprocessing
% Select one random audio sample for testing
adsClean = shuffle(adsClean);

% Reduce data set to speed up training at the cost of performance
reduceDataset = true;
if reduceDataset
    adsTrain = subset(adsClean,1:127);
end

switch params.dataset
    case 'large no aug'
        [adsTrain, adsVal] = splitEachLabel(adsClean, 0.9);
        adsTrain = transform(adsTrain,@(x)preprocess(x,adsNoise));
        adsVal = transform(adsVal,@(x)preprocess(x,adsNoise));
    case 'large with aug'
        [adsTrain, adsVal] = splitEachLabel(adsClean, 0.9);
        adsTrain = transform(adsTrain,@(x)preprocess_aug(x,adsNoise));
        adsVal = transform(adsVal,@(x)preprocess_aug(x,adsNoise));
    case 'small no aug'
        [adsTrain, adsVal] = splitEachLabel(adsClean, 0.7);
        adsTrain = transform(adsTrain,@(x)preprocess(x,adsNoise));
        adsVal = transform(adsVal,@(x)preprocess(x,adsNoise));
    case 'small with aug'
        [adsTrain, adsVal] = splitEachLabel(adsClean, 0.7);
        adsTrain = transform(adsTrain,@(x)preprocess_aug(x,adsNoise));
        adsVal = transform(adsVal,@(x)preprocess_aug(x,adsNoise));
end
    
%% Define network layers
% Speech Denoising with Fully Connected Layers
numFeatures = 129;
numSegments = 8;
layers = [
    imageInputLayer([numFeatures,numSegments])
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numFeatures)
    regressionLayer
    ];

%% Define network options
options = trainingOptions("adam", ...
    MaxEpochs=3, ...
    InitialLearnRate=1e-5,...
    MiniBatchSize=1, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.9, ...
    LearnRateDropPeriod=1, ...
    ValidationData=adsVal, ...
    VerboseFrequency=1000);
end