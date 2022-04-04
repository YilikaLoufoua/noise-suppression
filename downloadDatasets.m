function [cleanFilePath, noiseFilePath] = downloadDatasets(cleanUrl, noiseUrl)

% Download datasets
cleanFilePath = websave("clean_dataset.zip", cleanUrl);
noiseFilePath = websave("noise_dataset.zip", noiseUrl);

end