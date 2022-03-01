% Import clean audio dataset
dataFolder = "datasets_fullband/clean_fullband";
adsClean = audioDatastore(fullfile(dataFolder), 'LabelSource', 'foldernames');

% Reduce data set to speed up training at the cost of performance
reduceDataset = true;
if reduceDataset
    adsClean = shuffle(adsClean);
    adsClean = subset(adsClean,1:522);
end

% Import noise dataset
noiseFolder = "datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

% Divide adsClean into three transformed datastores containing 
% clean audios for training, validation, and testing.
[adsTrain, adsVal, adsTest] = splitEachLabel(adsClean, 0.98, 0.01);

% Define system parameters for generating predictor signals
keySet = {'win','overlap','ffTLength','inputFs','fs','numFeatures','numSegments','Bandwidth'};
valueSet = {hamming(256,"periodic"), round(0.75 * 256), 256, 48e3, 8e3, 129, 1, 7920};
params = containers.Map(keySet,valueSet);

% Extract the training and validation predictor and target magnitude STFT from the data set.
trainPredictors = transform(adsTrain, @(x) HelperGenerateSpeechDenoisingPredictors(x, adsNoise, params));
trainTargets = transform(adsTrain, @(x) HelperGenerateSpeechDenoisingTargets(x, params));
validatePredictors = transform(adsVal, @(x) HelperGenerateSpeechDenoisingPredictors(x, adsNoise, params));
validateTargets = transform(adsVal, @(x) HelperGenerateSpeechDenoisingTargets(x, params));

% Combine the clean and noisy audio into a single datastore that feeds data to trainNetwork
dsTrain = combine(trainPredictors, trainTargets);

% Speech Denoising with Fully Connected Layers
layers = [
    imageInputLayer([params('numFeatures'), params('numSegments')])
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(params('numFeatures'))
    regressionLayer
    ];

options = trainingOptions("adam", ...
    MaxEpochs=50, ...
    MiniBatchSize=64, ...
    ValidationData={validatePredictors, validateTargets}, ...
    ValidationPatience=5, ...
    Plots="training-progress", ...
    OutputNetwork="best-validation-loss", ...
    Verbose=false);

% Train the network
denoiseNetFullyConnected = trainNetwork(dsTrain, layers, options);

% Count the number of weights in the fully connected layers of the network.
numWeights = 0;
for index = 1:numel(denoiseNetFullyConnected.Layers)
    if isa(denoiseNetFullyConnected.Layers(index),"nnet.cnn.layer.FullyConnectedLayer")
        numWeights = numWeights + numel(denoiseNetFullyConnected.Layers(index).Weights);
    end
end

% Test the Denoising Network
cleanAudio = read(adsTest);

% Transform test audio to frequency-domain 
testPredictor = HelperGenerateSpeechDenoisingPredictors(x, adsNoise, params, src);
STFTFullyConnected = predict(denoiseNetFullyConnected, testPredictor);

% Reconstruct the time-domain signal.
denoisedAudioFullyConnected = istft(STFTFullyConnected,  ...
                                    'Window',params('win'),'OverlapLength',params('overlap'), ...
                                    'FFTLength',params('ffTLength'),'ConjugateSymmetric',true);

% Plot the clean, noisy and denoised audio signals
t = (1/fs) * (0:numel(denoisedAudioFullyConnected)-1);

figure

subplot(3,1,1)
plot(t,cleanAudio(1:numel(denoisedAudioFullyConnected)))
title("Clean Speech")
grid on

subplot(3,1,2)
plot(t,noisyAudio(1:numel(denoisedAudioFullyConnected)))
title("Noisy Speech")
grid on

subplot(3,1,3)
plot(t,denoisedAudioFullyConnected)
title("Denoised Speech (Fully Connected Layers)")
grid on
xlabel("Time (s)")

% Plot the clean, noisy, and denoised spectrograms.
h = figure;

subplot(3,1,1)
spectrogram(cleanAudio,win,overlap,ffTLength,fs);
title("Clean Speech")
grid on

subplot(3,1,2)
spectrogram(noisyAudio,win,overlap,ffTLength,fs);
title("Noisy Speech")
grid on

subplot(3,1,3)
spectrogram(denoisedAudioFullyConnected,win,overlap,ffTLength,fs);
title("Denoised Speech (Fully Connected Layers)")
grid on