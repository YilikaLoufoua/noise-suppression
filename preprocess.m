folderNoise = "C:\Users\saman\Documents\MATLAB\audioDenoise\datasets_fullband\datasets_fullband\noise_fullband\";
folderClean = "C:\Users\saman\Documents\MATLAB\audioDenoise\datasets_fullband\datasets_fullband\clean_fullband\read_speech\";
clean_files = dir(fullfile(folderClean,'*.wav'));
noise_files = dir(fullfile(folderNoise,'*.wav'));
clean_files_paths = {clean_files.name};
noise_files_paths = {noise_files.name};
clean_files_paths = strcat(folderClean, clean_files_paths);
noise_files_paths = strcat(folderNoise, noise_files_paths);
clean_files_paths = basicFiltering(clean_files_paths);
%  Before combine: preprocess clean (is_too_short, is_clipped_wav, is_low_activity, sample_rate==48000, length==10s, 8000hz)
%  During combine: combine noise, clean, rir(more research); 
%       temp solution: audioDataStore
%  After combine: 
%       Fourier tranform to sound graph
%

[y1,Fs] = audioread(clean_files_paths(1));
y1_sample_rate = Fs;
[y2,Fs] = audioread(noise_files_paths(1));
y2_sample_rate = Fs;

% audioPitch = pitch(y1,Fs);
% complex combine
y1_2 = y1(1:numel(y2));
noisePower = sum(y2.^2);
cleanPower = sum(y1.^2);
y2 = y2 .* sqrt(cleanPower/noisePower);
combinedAudio = y1_2 + y2;
sound(combinedAudio,y2_sample_rate)
% sound(y3, y1_sample_rate);

% sound(audioread(folderClean+'\'+clean_files(1).name));


function isUniformLength = checkLength(audio_files)  
    % filenames=zeros(1,length(audio_files));
    % lengths=zeros(1,length(audio_files));
    expectedLength = 10;
    for k=1:numel(audio_files)
        filename = audio_files(k);
        [y, Fs] = audioread(filename);
        time = length(y)./Fs;
        if(floor(time) ~= expectedLength)
            floor(time)
            isUniformLength = false;
            return;
        end
        % filenames(k) = filename;
        % lengths(k) = time;
    end
    isUniformLength = true;
end

