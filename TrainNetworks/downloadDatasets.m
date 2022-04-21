function [cleanFilePath, noiseFilePath] = downloadDatasets(cleanUrl, noiseUrl)

% Download datasets
cleanFilePath = websave("clean_dataset.tar.bz2", cleanUrl);
noiseFilePath = websave("noise_dataset.tat.bz2", noiseUrl);

end