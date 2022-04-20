function extractDatasets(cleanFilePath, noiseFilePath)

% Extract datasets
untar(cleanFilePath, "datasets_temp\");
untar(noiseFilePath, "datasets_temp\");

delete *.zip

end