function extractDatasets(cleanFilePath, noiseFilePath)

% Extract clean dataset
cmd = "bzip2 -d " + cleanFilePath;
system(cmd);

cleanFilePath = erase(cleanFilePath, '.bz2');
cmd = "tar -xf " + cleanFilePath + " -C ./datasets_temp";
system(cmd);

% Extract noise dataset
cmd = "bzip2 -d " + noiseFilePath;
system(cmd);

noiseFilePath = erase(noiseFilePath, '.bz2');
cmd = "tar -xf " + noiseFilePath + " -C ./dataset_temp";
system(cmd);

end