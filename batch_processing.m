cleanUrlList = ['https://filedropper.com/d/s/download/JgbbVRDPooDNEmub8ij2wffQJkT8in';'https://filedropper.com/d/s/download/TqjQexIp2786Z8bAi9IiCUWlkLVNQC'];
noiseUrlList = ['https://filedropper.com/d/s/download/ol8eD2PdZF3Q7gVgi52sctxCR99rpp';'https://filedropper.com/d/s/download/94n0xuKT98oxYcJTCzxHfX5AI6WFH8'];

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

% Initial training
[adsClean, adsNoise] = dataset_download(cleanUrlList(1, 1:end), noiseUrlList(1, 1:end));
net = train(adsClean, adsNoise, layers); 
rmdir datasets_temp\ s

% Retrain network
for i = 2:size(cleanUrlList,1)
    [adsClean, adsNoise] = dataset_download(cleanUrlList(i, 1:end), noiseUrlList(i, 1:end));
    net = train(adsClean, adsNoise, layerGraph(net)); 
    rmdir datasets_temp\ s
end