function data = HelperGenerateSpeechDenoisingFeatures(audio, noiseDataset)
% HelperGenerateSpeechDenoisingFeatures: Get target and predictor STFT
% signals for speech denoising.
% audio: Input audio signal
% noiseDataset: Noise dataset

WindowLength = 512;
win          = hamming(WindowLength,'periodic');
Overlap      = 512-256;
FFTLength    = WindowLength;
NumFeatures  = 257;
NumSegments  = 8;

% Convert from 48 Khz to 8 Khz
audio = resample(audio,1,6);

% Choose one noise file randomlyIf the noise file is invalid, choose another one.
noiseFiles = noiseDataset.Files;
ind = randi([1 length(noiseFiles)]);
noise = audioread(noiseFiles{ind});
while sum(isnan(noise)) > 0
    ind = randi([1 length(noiseFiles)]);
    noise = audioread(noiseFiles{ind});
end
noise = resample(noise,1,6);

% Adjust lengths of speech and noise signals
% if numel(audio)>=numel(noise)
%     audio = audio(1:numel(noise));
%     noiseSegment = noise;
% else
%     randind      = randi(numel(noise) - numel(audio) , [1 1]);
%     noiseSegment = noise(randind : randind + numel(audio) - 1);
% end

inputFs = 8000;
expected_length = 10;
noiseSegment = noise;
if numel(audio) > expected_length * inputFs
    audio = audio(1:expected_length * inputFs);
else
    blankSignal = zeros(expected_length * inputFs - numel(audio),1);
    audio = [audio; blankSignal];
end

if numel(noiseSegment) > expected_length * inputFs
    noiseSegment = noiseSegment(1:expected_length * inputFs);
else
    blankSignal = zeros(expected_length * inputFs - numel(noiseSegment),1);
    noiseSegment = [noiseSegment; blankSignal];
end


% Achieve some SNR
noisePower   = sum(noiseSegment.^2);
cleanPower   = sum(audio.^2);
noiseSegment = noiseSegment .* sqrt(cleanPower/noisePower);
noisyAudio   = audio + noiseSegment;

% Generate magnitude STFT vectors from the original and noisy audio signals.
cleanSTFT = stft(audio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
cleanSTFT = abs(cleanSTFT(NumFeatures-1:end,:));
noisySTFT = stft(noisyAudio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength);
noisySTFT = abs(noisySTFT(NumFeatures-1:end,:));

noisySTFTAugmented = [noisySTFT(:,1:NumSegments-1) noisySTFT];

% Generate the 8-segment training predictor signals from the noisy STFT. 
STFTSegments = zeros(NumFeatures, NumSegments , size(noisySTFTAugmented,2) - NumSegments + 1);
for index = 1 : size(noisySTFTAugmented,2) - NumSegments + 1
    STFTSegments(:,:,index) = noisySTFTAugmented(:,index:index+NumSegments-1);
end

targets    = cleanSTFT;
predictors = STFTSegments;

% Arrange in a cell array for trainNetwork
data = cell(size(targets,2),2);
for index=1:size(targets,2)
    data{index,1} = predictors(:,:,index);
    data{index,2} = targets(:,index);
end