function [adsTrain, layers, options] = RegressionExperiment_setup(params)

%% Import datasets
% Import clean audio dataset
dataFolder = "C:\Users\yilik\noise-suppression\datasets_fullband\clean_fullband";
adsClean = audioDatastore(fullfile(dataFolder), 'LabelSource', 'foldernames');

% Import noise dataset
noiseFolder = "C:\Users\yilik\noise-suppression\datasets_fullband\noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

%% Data preprocessing
% Select one random audio sample for testing
adsClean = shuffle(adsClean);

% Reduce data set to speed up training at the cost of performance
reduceDataset = true;
if reduceDataset
    adsClean = subset(adsClean,1:160);
end

% Use 80% of the dataset for training, 20 % for validation
[adsTrain, adsVal] = splitEachLabel(adsClean, 0.8);

% Extract the training predictor and target magnitude STFT
adsTrain = transform(adsTrain,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));
adsVal = transform(adsVal,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));

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
    MaxEpochs=params.epochs, ...
    InitialLearnRate=params.learnRate,...
    MiniBatchSize=params.miniBatchSize, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.9, ...
    LearnRateDropPeriod=1, ...
    ValidationData=adsVal, ...
    ValidationFrequency=2000);
end