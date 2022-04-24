cleanUrlList = ['https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/clean_fullband/datasets_fullband.clean_fullband.read_speech_003_3.96_4.02.tar.bz2';'https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/clean_fullband/datasets_fullband.clean_fullband.read_speech_001_3.75_3.88.tar.bz2';'https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/clean_fullband/datasets_fullband.clean_fullband.read_speech_002_3.88_3.96.tar.bz2'];
noiseUrlList = ['https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/noise_fullband/datasets_fullband.noise_fullband.audioset_001.tar.bz2';'https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/noise_fullband/datasets_fullband.noise_fullband.audioset_002.tar.bz2';'https://dns4public.blob.core.windows.net/dns4archive/datasets_fullband/noise_fullband/datasets_fullband.noise_fullband.audioset_003.tar.bz2'];


%% Import datasets
cleanFolder = "datasets_fullband/clean_fullband";
% adsTrain = audioDatastore(fullfile(cleanFolder), IncludeSubfolders=true);
noiseFolder = "datasets_fullband/noise_fullband";
% adsNoise = audioDatastore(fullfile(noiseFolder), IncludeSubfolders=true);

%% Initial training
% job_train = batch(@DenoiseTrain, 1, {true, layerGraph,cleanFolder,noiseFolder});
lg = layerGraph;
job_train = DenoiseTrain(true, lg,cleanFolder,noiseFolder);
disp('Batch 1 datasets: training started.')

cleanFolder = "../datasets_temp/datasets_fullband/clean_fullband";
noiseFolder = "../datasets_temp/datasets_fullband/noise_fullband";

% Retrain network
for i = 1:size(cleanUrlList,1)
    cleanUrl = cleanUrlList(i, 1:end);
    noiseUrl = noiseUrlList(i, 1:end);
    job_download = batch(@downloadDatasets, 2, {cleanUrl, noiseUrl});

    % Print message
    msg = 'Batch %d datasets: download started.\n';
    fprintf(msg, i);

    % wait(job_train);

    % Print message
    msg = 'Batch %d datasets: training completed.\n';
    fprintf(msg, i-1);

    wait(job_download);

    % Print message
    msg = 'Batch %d datasets: ready for training.\n';
    fprintf(msg, i);

    downloads = fetchOutputs(job_download);
    extractDatasets(downloads{1,1}, downloads{1,2});
    % result = fetchOutputs(job_train);
    % net = result{1,1};
    % rehash;
    % rehash path;
    % clear("../datasets_temp");
    % job_train = batch(@DenoiseTrain, 1, {false,net, });
    job_train = DenoiseTrain(false, job_train,cleanFolder,noiseFolder);

    % Print message
    msg = 'Batch %d datasets: training started.\n';
    fprintf(msg, i);

end

% wait(job_train);

% Print message
msg = 'Batch %d datasets: training completed.\n';
fprintf(msg, size(cleanUrlList,1));

% result = fetchOutputs(job_train);
net = job_train;
% delete(job_train);
delete(job_download);
clear job_download

function [percent_active] = check_activity(y, threshold)
    if ~exist('threshold','var')
        threshold=0.01;
     end
    percent_active = sum(abs(y) > threshold) / length(y);
end
