% Import clean audio dataset
dataFolder = "datasets_fullband/clean_fullband";
adsTrain = audioDatastore(fullfile(dataFolder));

reduceDataset = true;
if reduceDataset
    adsTrain = shuffle(adsTrain);
    adsTrain = subset(adsTrain,1:100);
end

% Import noise dataset
noiseFolder = "datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));

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

% Evaluate the targets and predictors.
[targets,predictors] = gather(targets,predictors);