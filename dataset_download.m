url = 'https://1drv.ms/u/s!Av2xQdGjCf2CrWlgtG8gLnE1iuEv?e=cNmNU2';
filepath = websave("dataset.zip", url);
unzip(filepath, "datasets_temp\");

% Get extracted folder name
folder = ls("datasets_temp\");
folder = folder(3,1:end); 
ads = audioDatastore("datasets_temp\" + folder);
[audio1, info] = read(ads);
sound(audio1, info.SampleRate);

% Delete all downloaded files after use
cd("datasets_temp\" + folder)
delete *.wav
cd ..\
rmdir(folder, 's')
cd ..\
delete *.zip

% Take new url
tic
url = "https://filedropper.com/d/s/download/J9PTlxn3FqtkziJxEGp3AaDtZtt6k4";
filepath = websave("dataset.zip", url);
unzip(filepath, "datasets_temp\");

% Get extracted folder name
folder = ls("datasets_temp\");
folder = folder(3, 1:end); 
ads = audioDatastore("datasets_temp\" + folder);
[audio1, info] = read(ads);
sound(audio1, info.SampleRate);

% Delete all downloaded files after use
cd("datasets_temp\" + folder)
delete *.wav
cd ..\
rmdir(folder)
cd ..\
delete *.zip
elapsedTime = toc;

urlList =  ['https://filedropper.com/d/s/download/3UK7zbMkJIW1jF7r0aSlfttUjidugB';'https://filedropper.com/d/s/download/J9PTlxn3FqtkziJxEGp3AaDtZtt6k4' ];
for index = 1:size(urlList,1)
    url = urlList(index, 1:end);
    filepath = websave("dataset.zip", url);
    unzip(filepath, "datasets_temp\");
    
    % Get extracted folder name
    folder = ls("datasets_temp\");
    folder = folder(3,1:end); 
    ads = audioDatastore("datasets_temp\" + folder);
    [audio1, info] = read(ads);
    sound(audio1, info.SampleRate);
    
    % Delete all downloaded files after use
    cd("datasets_temp\" + folder)
    delete *.wav
    cd ..\
    rmdir(folder)
    cd ..\
    delete *.zip
    pause(5)
    clear sound
end

% DNS challenge: clean_fullband/datasets_fullband.clean_fullband.read_speech_001_3.75_3.88.tar.bz2
tic
url = 'https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/clean_fullband/datasets_fullband.clean_fullband.read_speech_001_3.75_3.88.tar.bz2';
filepath = websave("dataset.tar.bz2", url);
elapsedTime = toc;
