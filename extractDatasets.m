function extractDatasets(cleanFilePath, noiseFilePath)

% Extract datasets
unzip(cleanFilePath, "datasets_temp\");
unzip(noiseFilePath, "datasets_temp\");

delete *.zip

end