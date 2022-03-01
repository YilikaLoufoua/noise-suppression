% Import clean audio dataset
dataFolder = "datasets_fullband/clean_fullband";
adsTrain = audioDatastore(fullfile(dataFolder));

reduceDataset = true;
if reduceDataset
    adsTrain = shuffle(adsTrain);
    adsTrain = subset(adsTrain,1:258);
end

% Import noise dataset
noiseFolder = "datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

% Keep one testing noise sample to not train with 
[testNoise,adsNoiseInfo] = read(adsNoise);
adsNoise = subset(adsNoise,2:length(adsNoise.Files));

% Define system parameters for generating target and predictor signals
windowLength = 256;
win = hamming(windowLength,"periodic");
overlap = round(0.75 * windowLength);
ffTLength = windowLength;
inputFs = 48e3;
fs = 8e3;
numFeatures = ffTLength/2 + 1;
numSegments = 8;

% Create a sample rate converter to convert the 48 kHz audio to 8 kHz
src = dsp.SampleRateConverter("InputSampleRate",inputFs, ...
                              "OutputSampleRate",fs, ...
                              "Bandwidth",7920);

% Extract Features Using Tall Arrays
T = tall(adsTrain);

% Extract the target and predictor magnitude STFT from the tall table.
% The function HelperGenerateSpeechDenoisingFeatures generates targets and
% predictors at each cell
[targets,predictors] = cellfun(@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise,src),T,"UniformOutput",false);
targets = targets(cellfun(@(x) ~isequal(x, 0), targets));
predictors = predictors(cellfun(@(x) ~isequal(x, 0), predictors));

% Evaluate the targets and predictors.
[targets,predictors] = gather(targets,predictors);

% Normalize the targets and predictors using their respective mean and
% standard deviation
predictors = cat(3,predictors{:});
noisyMean = mean(predictors(:));
noisyStd = std(predictors(:));
predictors(:) = (predictors(:) - noisyMean)/noisyStd;

targets = cat(2,targets{:});
cleanMean = mean(targets(:));
cleanStd = std(targets(:));
targets(:) = (targets(:) - cleanMean)/cleanStd;

% Reshape predictors and targets to the dimensions expected by the deep learning networks.
predictors = reshape(predictors,size(predictors,1),size(predictors,2),1,size(predictors,3));
targets = reshape(targets,1,1,size(targets,1),size(targets,2));

% Randomly split the data into training and validation sets with 1% of the 
% data for vaildation
inds = randperm(size(predictors,4));
L = round(0.99 * size(predictors,4));

trainPredictors = predictors(:,:,:,inds(1:L));
trainTargets = targets(:,:,:,inds(1:L));

validatePredictors = predictors(:,:,:,inds(L+1:end));
validateTargets = targets(:,:,:,inds(L+1:end));

% Define the layers of the network using fully connected layers
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

% Specify the training options for the network.
miniBatchSize = 32;
options = trainingOptions("adam", ...
    "MaxEpochs",3, ...
    "InitialLearnRate",1e-5,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...
    "Plots","training-progress", ...
    "Verbose",false, ...
    "ValidationFrequency",floor(size(trainPredictors,4)/miniBatchSize), ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",1, ...
    "ValidationData",{validatePredictors,validateTargets});

% Train the network
denoiseNetFullyConnected = trainNetwork(trainPredictors,trainTargets,layers,options);

% Count the number of weights in the fully connected layers of the network.
numWeights = 0;
for index = 1:numel(denoiseNetFullyConnected.Layers)
    if isa(denoiseNetFullyConnected.Layers(index),"nnet.cnn.layer.FullyConnectedLayer")
        numWeights = numWeights + numel(denoiseNetFullyConnected.Layers(index).Weights);
    end
end
fprintf("The number of weights is %d.\n",numWeights);

% Test the Denoising Network
ads = audioDatastore(fullfile(dataFolder));

% Read the contents of a random file from the datastore.
ads = shuffle(ads);
[cleanAudio,adsTestInfo] = read(ads);

% Set the audio samples to uniform length of 10 seconds
inputFs = 48000;
expected_length = 10;
if length(cleanAudio) > expected_length * inputFs
    cleanAudio = cleanAudio(1:expected_length * inputFs);
else
    blankSignal = zeros(expected_length * inputFs - length(cleanAudio),1);
    cleanAudio = [cleanAudio; blankSignal];
end

if length(testNoise) > expected_length * inputFs
    testNoise = testNoise(1:expected_length * inputFs);
else
    blankSignal = zeros(expected_length * inputFs - length(testNoise),1);
    testNoise = [testNoise; blankSignal];
end

% Make sure the audio length is a multiple of the sample rate converter decimation factor.
decimationFactor = inputFs/fs;
L = floor(numel(cleanAudio)/decimationFactor);
cleanAudio = cleanAudio(1:decimationFactor*L);
testNoise = testNoise(1:decimationFactor*L);

% Downsample the signals
cleanAudio = src(cleanAudio);
reset(src);
testNoise = src(testNoise);
reset(src);

% Corrupt speech with a random noise sample not used in the training stage.
speechPower = sum(cleanAudio.^2);
noisePower = sum(testNoise.^2);
noisyAudio = cleanAudio + sqrt(speechPower/noisePower) * testNoise;

% Generate magnitude STFT vectors from the noisy audio signals.
noisySTFT = stft(noisyAudio,'Window',win,'OverlapLength',overlap,'FFTLength',ffTLength);
noisyPhase = angle(noisySTFT(numFeatures-1:end,:));
noisySTFT = abs(noisySTFT(numFeatures-1:end,:));

% Generate the 8-segment training predictor signals from the noisy STFT.
noisySTFT = [noisySTFT(:,1:numSegments-1) noisySTFT];
predictors = zeros( numFeatures, numSegments , size(noisySTFT,2) - numSegments + 1);
for index = 1:(size(noisySTFT,2) - numSegments + 1)
    predictors(:,:,index) = noisySTFT(:,index:index + numSegments - 1); 
end

% Normalize the predictors by the mean and standard deviation computed in the training stage.
predictors(:) = (predictors(:) - noisyMean) / noisyStd;

% Compute the denoised magnitude STFT by using predict
predictors = reshape(predictors, [numFeatures,numSegments,1,size(predictors,3)]);
STFTFullyConnected = predict(denoiseNetFullyConnected, predictors);

% Scale the outputs by the mean and standard deviation used in the training stage.
STFTFullyConnected(:) = cleanStd * STFTFullyConnected(:) + cleanMean;

% Convert the one-sided STFT to a centered STFT.
STFTFullyConnected = STFTFullyConnected.' .* exp(1j*noisyPhase);
STFTFullyConnected = [conj(STFTFullyConnected(end-1:-1:2,:)); STFTFullyConnected];

% Compute the denoised speech signals.
denoisedAudioFullyConnected = istft(STFTFullyConnected,  ...
                                    'Window',win,'OverlapLength',overlap, ...
                                    'FFTLength',ffTLength,'ConjugateSymmetric',true);

% Plot the clean, noisy and denoised audio signals.
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

p = get(h,'Position');
set(h,'Position',[p(1) 65 p(3) 800]);

% sound(noisyAudio,fs)
% sound(denoisedAudioFullyConnected,fs)
% sound(cleanAudio,fs)
