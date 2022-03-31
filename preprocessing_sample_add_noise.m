% Import clean audio dataset
dataFolder = "datasets_fullband/clean_fullband";
adsClean = audioDatastore(fullfile(dataFolder), 'LabelSource', 'foldernames');

% Import noise dataset
noiseFolder = "datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

% Select one random audio sample for testing
adsClean = shuffle(adsClean);
adsTest = subset(adsClean, 1:1);

% Reduce data set to speed up training at the cost of performance
reduceDataset = true;
if reduceDataset
    adsTrain = subset(adsClean,2:33);
end

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
    MiniBatchSize=16, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.9, ...
    LearnRateDropPeriod=1);

% Train the network
denoiseNetFullyConnected = trainNetwork(adsTrain, layers, options);

% Test the Denoising Network
[testAudio, adsTestInfo] = read(adsTest);

% Convert from 48 Khz to 8 Khz
testAudio = resample(testAudio,1,6);

% Choose one noise file randomly. If the noise file is invalid, choose another one.
noiseFiles = adsNoise.Files;
ind = randi([1 length(noiseFiles)]);
noise = audioread(noiseFiles{ind});
while sum(isnan(noise)) > 0
    ind = randi([1 length(noiseFiles)]);
    noise = audioread(noiseFiles{ind});
end
noise = resample(noise,1,6);

% Adjust lengths of speech and noise signals
if numel(testAudio)>=numel(noise)
    testAudio = testAudio(1:numel(noise));
    noiseSegment = noise;
else
    randind      = randi(numel(noise) - numel(testAudio) , [1 1]);
    noiseSegment = noise(randind : randind + numel(testAudio) - 1);
end

% Achieve some SNR
noisePower   = sum(noiseSegment.^2);
cleanPower   = sum(testAudio.^2);
noiseSegment = noiseSegment .* sqrt(cleanPower/noisePower);
noisyAudio   = testAudio + noiseSegment;

% Generate magnitude STFT vectors from the noisy audio signal.
WindowLength = 256;
win          = hamming(WindowLength,'periodic');
Overlap      = round(0.75 * WindowLength);
FFTLength    = WindowLength;
NumFeatures  = FFTLength/2 + 1;
NumSegments  = 8;

noisySTFT = stft(noisyAudio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
noisyPhase = angle(noisySTFT(numFeatures-1:end,:));
noisySTFT = abs(noisySTFT(NumFeatures-1:end,:));

noisySTFTAugmented = [noisySTFT(:,1:NumSegments-1) noisySTFT];

% Generate the 8-segment training predictor signals from the noisy STFT. 
STFTSegments = zeros(NumFeatures, NumSegments , size(noisySTFTAugmented,2) - NumSegments + 1);
for index = 1 : size(noisySTFTAugmented,2) - NumSegments + 1
    STFTSegments(:,:,index) = noisySTFTAugmented(:,index:index+NumSegments-1);
end

predictors = STFTSegments;

% Compute the denoised magnitude STFT 
predictors = reshape(predictors,[numFeatures,numSegments,1,size(predictors,3)]);
STFTFullyConnected = predict(denoiseNetFullyConnected,predictors);

% Convert the one-sided STFT to a centered STFT.
STFTFullyConnected = (STFTFullyConnected.').*exp(1j*noisyPhase);
STFTFullyConnected = [conj(STFTFullyConnected(end-1:-1:2,:));STFTFullyConnected];

% Compute the denoised speech signals.
denoisedAudioFullyConnected = istft(STFTFullyConnected,Window=win,OverlapLength=Overlap,fftLength=FFTLength,ConjugateSymmetric=true);                       

% Plot the clean, noisy and denoised audio signals.
fs = 8000;
t = (1/fs)*(0:numel(denoisedAudioFullyConnected)-1);

figure(2)
tiledlayout(3,1)

nexttile
plot(t,testAudio(1:numel(denoisedAudioFullyConnected)))
title("Clean Speech")
grid on

nexttile
plot(t,noisyAudio(1:numel(denoisedAudioFullyConnected)))
title("Noisy Speech")
grid on

nexttile
plot(t,denoisedAudioFullyConnected)
title("Denoised Speech")
grid on
xlabel("Time (s)")

% Plot the clean, noisy, and denoised spectrograms.
h = figure(3);
tiledlayout(3,1)

nexttile
spectrogram(testAudio,win,Overlap,FFTLength,fs);
title("Clean Speech")
grid on

nexttile
spectrogram(noisyAudio,win,Overlap,FFTLength,fs);
title("Noisy Speech")
grid on

nexttile
spectrogram(denoisedAudioFullyConnected,win,Overlap,FFTLength,fs);
title("Denoised Speech (Fully Connected Layers)")
grid on

p = get(h,"Position");
set(h,"Position",[p(1) 65 p(3) 800]);