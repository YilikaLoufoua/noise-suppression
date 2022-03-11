% Import clean audio dataset
dataFolder = "datasets_fullband/clean_fullband";
adsClean = audioDatastore(fullfile(dataFolder), 'LabelSource', 'foldernames');

% Reduce data set to speed up training at the cost of performance
reduceDataset = true;
if reduceDataset
    adsClean = shuffle(adsClean);
    adsClean = subset(adsClean,1:512);
end

% Import noise dataset
noiseFolder = "datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

% Extract the training predictor and target magnitude STFT
adsTrain = transform(adsTrain,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));

% Speech Denoising with Fully Connected Layers
numFeatures = 129;
numSegments = 8;
layers = [
    imageInputLayer([numFeatures, numSegments])
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numFeatures)
    regressionLayer
    ];

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

% Train the network
denoiseNetFullyConnected = trainNetwork(adsTrain, layers, options);
