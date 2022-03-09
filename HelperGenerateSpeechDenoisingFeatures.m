function data = HelperGenerateSpeechDenoisingFeatures(audio,noiseDataset)
% HelperGenerateSpeechDenoisingFeatures: Get target and predictor STFT
% signals for speech denoising.
% audio: Input audio signal
% noiseDataset: Noise dataset

% Copyright 2018-2022 The MathWorks, Inc.

WindowLength = 512;
win          = hamming(WindowLength,'periodic');
Overlap      = 512-256;
FFTLength    = WindowLength;
NumFeatures  = FFTLength/2 + 1;
NumSegments  = 8;

% Convert from 16 Khz to 8 Khz
audio = resample(audio,1,2);

noiseFiles = noiseDataset.Files;
% Choose one noise file randomly
ind = randi([1 length(noiseFiles)]);
noise = audioread(noiseFiles{ind});
% Adjust lengths of speech and noise signals
if numel(audio)>=numel(noise)
    audio = audio(1:numel(noise));
    noiseSegment = noise;
else
    randind      = randi(numel(noise) - numel(audio) , [1 1]);
    noiseSegment = noise(randind : randind + numel(audio) - 1);
end

% Achieve some SNR
noisePower   = sum(noiseSegment.^2);
cleanPower   = sum(audio.^2);
noiseSegment = noiseSegment .* sqrt(cleanPower/noisePower);
noisyAudio   = audio + noiseSegment;

cleanSTFT = stft(audio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
cleanSTFT = abs(cleanSTFT(NumFeatures-1:end,:));
noisySTFT = stft(noisyAudio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
noisySTFT = abs(noisySTFT(NumFeatures-1:end,:));

noisySTFTAugmented = [noisySTFT(:,1:NumSegments-1) noisySTFT];

% Noisy "predictors" are 129-by-8
% Clean "targets" are 129-by-1
STFTSegments = zeros(NumFeatures, NumSegments , size(noisySTFTAugmented,2) - NumSegments + 1);
for index = 1 : size(noisySTFTAugmented,2) - NumSegments + 1
    STFTSegments(:,:,index) = noisySTFTAugmented(:,index:index+NumSegments-1);
end

targets    = cleanSTFT;
predictors = STFTSegments;

% Arrange in a cell array for trainNetwork
% Note that one training speech file can yield one or more target/predictor
% pairs. Depends on how long the audio is.
data = cell(size(targets,2),2);
for index=1:size(targets,2)
    data{index,1} = predictors(:,:,index);
    data{index,2} = targets(:,index);
end