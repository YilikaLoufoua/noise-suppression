function data = HelperGenerateSpeechDenoisingFeatures(audio, noiseDataset)
% HelperGenerateSpeechDenoisingFeatures: Get target and predictor STFT
% signals for speech denoising.
% audio: Input audio signal
% noiseDataset: Noise dataset

WindowLength = 256;
win          = hamming(WindowLength,'periodic');
Overlap      = round(0.75 * WindowLength);
FFTLength    = WindowLength;
NumFeatures  = FFTLength/2 + 1;

% Convert from 48 Khz to 8 Khz
audio = resample(audio,1,6);

% Choose one noise file randomly. If the noise file is invalid, choose another one.
noiseFiles = noiseDataset.Files;
ind = randi([1 length(noiseFiles)]);
noise = audioread(noiseFiles{ind});
while sum(isnan(noise)) > 0
    ind = randi([1 length(noiseFiles)]);
    noise = audioread(noiseFiles{ind});
end
noise = resample(noise,1,6);

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

% Generate magnitude STFT vectors from the original and noisy audio signals.
[cleanSTFT, cleanFrequencies, cleanTimeInstants] = stft(audio, 'Window', win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
cleanSTFT = abs(cleanSTFT);
[noisySTFT, noisyFrenqeuncies, noisyTimeInstants] = stft(noisyAudio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
noisySTFT = abs(noisySTFT(NumFeatures-1:end,:));

% Reshape magnitude STFT vectors
cleanSTFT = reshape(cleanSTFT,1,1,numel(cleanFrequencies),numel(cleanTimeInstants));
noisySTFT = reshape(noisySTFT,1,1,numel(noisyFrenqeuncies),numel(noisyTimeInstants));

targets    = cleanSTFT;
predictors = noisySTFT;

% Arrange in a cell array for trainNetwork
data = cell(size(targets,2),2);
for index=1:size(targets,2)
    data{index,1} = predictors(:,:,index);
    data{index,2} = targets(:,index);
end