function net = train_network(layers)

% Define system parameters for generating target and predictor signals
windowLength = 256;
win = hamming(windowLength,"periodic");
overlap = round(0.75 * windowLength);
ffTLength = windowLength;
inputFs = 48e3;
fs = 8e3;
numFeatures = ffTLength/2 + 1;
numSegments = 8;

% Import datasets
downloadedfolders = ls("datasets_temp\");
cleanFolder = append('datasets_temp\', downloadedfolders(3,1:end)); 
adsClean = audioDatastore(cleanFolder);
noiseFolder = append('datasets_temp\', downloadedfolders(4,1:end)); 
adsNoise = audioDatastore(noiseFolder);

% Create a sample rate converter to convert the 48 kHz audio to 8 kHz
src = dsp.SampleRateConverter("InputSampleRate",inputFs, ...
                              "OutputSampleRate",fs, ...
                              "Bandwidth",7920);

% Extract Features Using Tall Arrays
T = tall(adsClean);

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

% Specify the training options for the network.
miniBatchSize = 16;
options = trainingOptions("adam", ...
    "MaxEpochs",1, ...
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
net = trainNetwork(trainPredictors,trainTargets,layers,options);

% Delet used training data
rmdir datasets_temp\ s

end