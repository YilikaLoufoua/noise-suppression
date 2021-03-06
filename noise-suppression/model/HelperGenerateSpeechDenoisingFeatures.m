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

inputFs = 8000;
expected_length = 3;

% Convert from 48 Khz to 8 Khz
audio = resample(audio,1,6);

% Choose one noise file randomlyIf the noise file is invalid, choose another one.
noiseFiles = noiseDataset.Files;
ind = randi([1 length(noiseFiles)]);
noise = audioread(noiseFiles{ind});

activity_threshold = 0.01;
noise_activity = check_activity(noise(1:expected_length * inputFs));
while sum(isnan(noise)) > 0 || noise_activity < activity_threshold
    % message = "finding another...."+noise_activity
    ind = randi([1 length(noiseFiles)]);
    noise = audioread(noiseFiles{ind});
    noise_activity = check_activity(noise(1:expected_length * inputFs));
end
% message2 = "found it!" + noise_activity
noise = resample(noise,1,6);

% Adjust lengths of speech and noise signals
% if numel(audio)>=numel(noise)
%     audio = audio(1:numel(noise));
%     noiseSegment = noise;
% else
%     randind      = randi(numel(noise) - numel(audio) , [1 1]);
%     noiseSegment = noise(randind : randind + numel(audio) - 1);
% end


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
cleanSTFTComp = stft(audio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength,"FrequencyRange","onesided");
% cleanSTFTComp = cleanSTFTComp(NumFeatures-1:end,:);
noisySTFTComp = stft(noisyAudio, 'Window',win, 'OverlapLength', Overlap, 'FFTLength',FFTLength,"FrequencyRange","onesided");
% noisySTFTComp = noisySTFTComp(NumFeatures-1:end,:);
noisySTFT = abs(noisySTFTComp);
cleanSTFT = buld_complex_ideal_ratio_mask(real(noisySTFTComp),imag(noisySTFTComp),real(cleanSTFTComp),imag(cleanSTFTComp));

targets    = cleanSTFT;
predictors = noisySTFT;

% Arrange in a cell array for trainNetwork
data = cell(1,2);
data{1,1} = predictors;
data{1,2} = targets;
end

function [percent_active] = check_activity(y, threshold)
    if ~exist('threshold','var')
        threshold=0.01;
     end
    percent_active = sum(abs(y) > threshold) / length(y);
end