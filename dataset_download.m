function [adsClean, adsNoise] = dataset_download(cleanUrl, noiseUrl)

% Make temporary dataset folder
mkdir datasets_temp

% Download clean audio dataset
filepath = websave("dataset.zip", cleanUrl);
unzip(filepath, "datasets_temp\");
delete *.zip

% Get extracted folder name
downloadedfolder = ls("datasets_temp\");
cleanFolder = downloadedfolder(3,1:end); 
adsClean = audioDatastore("datasets_temp\" + cleanFolder);

% Download noise audio dataset
filepath = websave("dataset.zip", noiseUrl);
unzip(filepath, "datasets_temp\");
delete *.zip

% Get extracted folder name
downloadedfolder = ls("datasets_temp\");
noiseFolder = downloadedfolder(4,1:end); 
adsNoise = audioDatastore("datasets_temp\" + noiseFolder);

end