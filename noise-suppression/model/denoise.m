clear all
close all
clc

%% load the net
load('denoiseNet.mat');

%% choose the speech
[file,path] = uigetfile('./Databases/*.wav', 'Select the speech files', 'MultiSelect', 'on'); 
[audio, fs] = audioread([path,file]);

%% Generate magnitude STFT vectors from the noisy audio signal.
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

% Generate the 8-segment predictor signals from the noisy STFT. 
STFTSegments = zeros(NumFeatures, NumSegments , size(noisySTFTAugmented,2) - NumSegments + 1);
for index = 1 : size(noisySTFTAugmented,2) - NumSegments + 1
    STFTSegments(:,:,index) = noisySTFTAugmented(:,index:index+NumSegments-1);
end

predictors = STFTSegments;

% Compute the denoised magnitude STFT 
predictors = reshape(predictors,[numFeatures,numSegments,1,size(predictors,3)]);
STFTDenoised = predict(denoiseNetFullyConnected,predictors);

% Convert the one-sided STFT to a centered STFT.
STFTDenoised = (STFTDenoised.').*exp(1j*noisyPhase);
STFTDenoised = [conj(STFTDenoised(end-1:-1:2,:));STFTDenoised];

% Compute the denoised speech signals and save.
denoisedAudio = istft(STFTDenoised,Window=win,OverlapLength=Overlap,fftLength=FFTLength,ConjugateSymmetric=true);
save('denoisedAudio.wav','denoisedAudio')

