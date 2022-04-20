% filename = websave("audioRead.tar.bz2","https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/clean_fullband/datasets_fullband.clean_fullband.VocalSet_48kHz_mono_000_NA_NA.tar.bz2");
filename = 'C:\Users\saman\Documents\MATLAB\noise-suppression\data\audioRead.tar.bz2';
% urlwrite(fullURL,filename);
cmd = "bzip2 -d " + filename;
system(cmd);
%% 
filename = 'C:\Users\saman\Documents\MATLAB\noise-suppression\data\audioRead.tar';
cmd = "tar -xf " + filename + " -C ./dataset";
system(cmd);