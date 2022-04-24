function extractDatasets(cleanFilePath, noiseFilePath)
cleanFilePath
% rmdir('datasets_temp', 's');
% mkdir datasets_temp;

% Extract clean dataset
cmd = "bzip2 -d " + cleanFilePath;
system(cmd);

cleanFilePath = erase(cleanFilePath, '.bz2');
cmd = "tar -xf " + cleanFilePath + " -C ../datasets_temp";
system(cmd);
delete(cleanFilePath);

% Extract noise dataset
cmd = "bzip2 -d " + noiseFilePath;
system(cmd);
 
noiseFilePath = erase(noiseFilePath, '.bz2');
cmd = "tar -xf " + noiseFilePath + " -C ../datasets_temp";
system(cmd);
delete(noiseFilePath);
noiseFilePath

end