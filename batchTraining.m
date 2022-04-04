cleanUrlList = ['https://filedropper.com/d/s/download/JgbbVRDPooDNEmub8ij2wffQJkT8in';'https://filedropper.com/d/s/download/TqjQexIp2786Z8bAi9IiCUWlkLVNQC';'https://filedropper.com/d/s/download/TqjQexIp2786Z8bAi9IiCUWlkLVNQC'];
noiseUrlList = ['https://filedropper.com/d/s/download/ol8eD2PdZF3Q7gVgi52sctxCR99rpp';'https://filedropper.com/d/s/download/94n0xuKT98oxYcJTCzxHfX5AI6WFH8';'https://filedropper.com/d/s/download/94n0xuKT98oxYcJTCzxHfX5AI6WFH8'];

% Define system parameters for generating target and predictor signals
windowLength = 256;
win = hamming(windowLength,"periodic");
overlap = round(0.75 * windowLength);
ffTLength = windowLength;
inputFs = 48e3;
fs = 8e3;
numFeatures = ffTLength/2 + 1;
numSegments = 8;

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

% Download first batch > download done: extract first batch > train on first batch + download second batch >
% train done: delete first batch + wait for download > download done: extract second batch  > 
% train on second batch and download third batch

% Initial training
tic
cleanUrl = cleanUrlList(1,1:end);
noiseUrl = noiseUrlList(1,1:end);
[cleanFilePath, noiseFilePath] = downloadDatasets(cleanUrl, noiseUrl);
disp('Downloading batch 1 of datasets')
extractDatasets(cleanFilePath, noiseFilePath);
job_train = batch(@train_network, 1, {layers});
disp('Training on batch 1 of datasets')
% net = train_network(layers); % Experiment w/o parallel process

% Retrain network
for i = 2:size(cleanUrlList,1)
    cleanUrl = cleanUrlList(i, 1:end);
    noiseUrl = noiseUrlList(i, 1:end);
    job_download = batch(@downloadDatasets, 2, {cleanUrl, noiseUrl});

    % Print message
    msg = 'Downloading batch %d of datasets\n';
    fprintf(msg, i);

%   downloadDatasets(cleanUrl, noiseUrl); % Experiment w/o parallel process
    wait(job_train);
    wait(job_download);
    downloads = fetchOutputs(job_download);
    extractDatasets(downloads{1,1}, downloads{1,2});
    result = fetchOutputs(job_train);
    net = result{1,1};
    job_train = batch(@train_network, 1, {layerGraph(net)});

    % Print message
    msg = 'Training on batch %d of datasets\n';
    fprintf(msg, i);


%   net = train_network(layerGraph(net)); % Experiment w/o parallel process
end

wait(job_train);
result = fetchOutputs(job_train);
net = result{1,1};
delete(job_train);
delete(job_download);
clear job_train job_download
toc

% Test the Denoising Network
adsTest = audioDatastore("datasets_fullband\clean_fullband\");
adsNoise = audioDatastore("datasets_fullband\noise_fullband\");
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
STFTFullyConnected = predict(net,predictors);

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