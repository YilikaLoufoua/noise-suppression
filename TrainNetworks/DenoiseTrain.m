function net = DenoiseTrain(layers)

%% --------Calculate the band filter---------
w_b=get_wb();
%% --------------------

% Import datasets
cleanFolder = "datasets_temp/clean_fullband";
adsTrain = audioDatastore(fullfile(cleanFolder), IncludeSubfolders=true);
noiseFolder = "datasets_temp/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder), IncludeSubfolders=true);

N1=size(adsTrain.Files,1); %Number of speech segments read
frameLength=0.02; %framelength
frameOverlap=0.01; %frameoverlap
fs=8000;%sample rate
giveMFCCnums=8; %MFCC def
numberPBs=4; %tones
windowLength=frameLength*fs;
windowOverlap=frameOverlap*fs;
SNR=0;
number_MFCCs=16; %MFCC order

% ----------MFCC define
for k=1:number_MFCCs %DCT
    n=0:2*number_MFCCs-1;
    dctcoef(k,:)=cos((2*n+1)*k*pi/(2*2*number_MFCCs));
end
bank=melbankm(2*number_MFCCs,windowLength,fs,0,0.5,'t');
%mel filter bank
bank=full(bank);
bank=bank/max(bank(:));
%window
N=windowLength;
m=0:N-1;
K=1;%sine order
sineWindow=sin((pi * K * (m+1))/(N+1));
%% --------------processing N speech---------------------
for j=1:N1
    j
    audio=audioread(adsTrain.Files{j});
    % If the audio file is invalid, choose the next one.
    activity_threshold = 0.01;
    inputFs = 48000;
    expected_length = 10;
    audio_activity = check_activity(audio(1:expected_length * inputFs));
    if sum(isnan(audio)) > 0 || audio_activity < activity_threshold
        continue
    end
    %% -----------select noise signal----------------------
    % Choose one noise file randomly. If the noise file is invalid, choose another one.
    noiseFiles = adsNoise.Files;
    ind = randi([1 length(noiseFiles)]);
    noise = audioread(noiseFiles{ind});
    
    activity_threshold = 0.01;
    inputFs = 48000;
    expected_length = 10;
    noise_activity = check_activity(noise(1:expected_length * inputFs));
    while sum(isnan(noise)) > 0 || noise_activity < activity_threshold
        ind = randi([1 length(noiseFiles)]);
        noise = audioread(noiseFiles{ind});
        noise_activity = check_activity(noise(1:expected_length * inputFs));
    end
    %% -----------sample rate reset-------------------------
    audio = resample(audio,1,6);
    noise = resample(noise,1,6);
    %% -----------combine clean and noise signals-----------
    % Set the audio samples to uniform length of 10 seconds
    if length(audio) > expected_length * fs
        audio = audio(1:expected_length * fs);
    else
        blankSignal = zeros(expected_length * fs - length(audio),1);
        audio = [audio; blankSignal];
    end
    
    if length(noise) > expected_length * fs
        noise = noise(1:expected_length * fs);
    else
        blankSignal = zeros(expected_length * fs - length(noise),1);
        noise = [noise; blankSignal];
    end
    % Set the noise power such that the signal-to-noise ratio (SNR) is zero dB
    speechPower = sum(audio.^2);
    noisePower = sum(noise.^2);
    noisyAudio = audio + sqrt(speechPower/noisePower) * noise;
    %% window and frame
    i=1;
    MFCC_noisy=zeros(round((size(noisyAudio,1)-windowLength)/windowOverlap),number_MFCCs+giveMFCCnums);
    noisyFrame=zeros(round((size(noisyAudio,1)-windowLength)/windowOverlap),windowLength);
    audioFrame=zeros(round((size(noisyAudio,1)-windowLength)/windowOverlap),windowLength);
    while windowLength+(i-1)*windowOverlap<size(noisyAudio,1)
        noisyFrame(i,:)=noisyAudio((i-1)*windowOverlap+1:(i-1)*windowOverlap+windowLength);
        noisyFrame(i,:)=noisyFrame(i,:).*sineWindow;
        audioFrame(i,:)=audio((i-1)*windowOverlap+1:(i-1)*windowOverlap+windowLength);
        audioFrame(i,:)=audioFrame(i,:).*sineWindow;
        s=noisyFrame(i,:);
        t=abs(fft(s)); 
        t=t.^2; 
        c=dctcoef*log(bank*t(1:windowLength/2+1)'); %Mel
        MFCC_noisy(i,1:number_MFCCs)=c'; 
        MFCC_noisy(i,number_MFCCs+1:number_MFCCs+giveMFCCnums)=getMFCCdet(c',giveMFCCnums);

        i=i+1;
    end

    g_b=zeros(size(audioFrame,1),17);
    %% calculate g_b
    for numberFrame=1:size(audioFrame,1)
        tempNoisyFrame=noisyFrame(numberFrame,:);
        tempAudioFrame=audioFrame(numberFrame,:);
        tempAudioFrame_f=fft(tempAudioFrame);
        tempAudioFrame_f_abs=abs(tempAudioFrame_f);
        tempAudioFrame_f_abs_sq=tempAudioFrame_f_abs.^2;
        tempNoisyFrame_f=fft(tempNoisyFrame);
        tempNoisyFrame_f_abs=abs(tempNoisyFrame_f);
        tempNoisyFrame_f_abs_sq=tempNoisyFrame_f_abs.^2;
        Ex_b=zeros(1,size(w_b,1));
        Es_b=zeros(1,size(w_b,1));
        for b=1:size(w_b,1)
            Es_b(1,b)=sum(tempAudioFrame_f_abs_sq.*w_b(b,:));
            Ex_b(1,b)=sum(tempNoisyFrame_f_abs_sq.*w_b(b,:));
        end
        g_b(numberFrame,:)=sqrt(Es_b./Ex_b);
    end
    %% data synthesis
    if (j==1)
        MFCC_noisy_all=MFCC_noisy;
        g_b_all=g_b;
    else
        if sum(sum(isnan(g_b))) > 0 || sum(sum(isnan(MFCC_noisy))) > 0
            continue
        end
        MFCC_noisy_all=[MFCC_noisy_all;MFCC_noisy];
        g_b_all=[g_b_all;g_b];
    end
end

% network define
lgraph = layerGraph();

tempLayers = featureInputLayer(size(MFCC_noisy_all,2),"Name","featureinput");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    fullyConnectedLayer(24,"Name","fc_1")
    tanhLayer("Name","tanh")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    gruLayer(24,"Name","gru_1")
    reluLayer("Name","relu_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(1,3,"Name","concat_1")
    gruLayer(96,"Name","gru_2")
    reluLayer("Name","relu_2")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    concatenationLayer(1,3,"Name","concat_2")
    fullyConnectedLayer(17,"Name","fc_2")
    sigmoidLayer("Name","sigmoid")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);

% clean up helper variable
clear tempLayers;

lgraph = connectLayers(lgraph,"featureinput","fc_1");
lgraph = connectLayers(lgraph,"featureinput","concat_1/in1");
lgraph = connectLayers(lgraph,"featureinput","concat_2/in3");
lgraph = connectLayers(lgraph,"tanh","gru_1");
lgraph = connectLayers(lgraph,"tanh","concat_1/in2");
lgraph = connectLayers(lgraph,"relu_1","concat_1/in3");
lgraph = connectLayers(lgraph,"relu_1","concat_2/in2");
lgraph = connectLayers(lgraph,"relu_2","concat_2/in1");

%% -----------training network
% training options
options = trainingOptions('adam',...
    "InitialLearnRate",1e-5, ...
    'MaxEpochs',1,..., ...
    'MiniBatchSize',16, ...,
    'Shuffle','every-epoch',...
    'Verbose',false,...
    'Plots','training-progress',...
    'ExecutionEnvironment','cpu');

% train and save
net = trainNetwork(MFCC_noisy_all,g_b_all,layers,options);
save('DenoiseNet0419.mat','net')

function [percent_active] = check_activity(y, threshold)
    if ~exist('threshold','var')
        threshold=0.01;
     end
    percent_active = sum(abs(y) > threshold) / length(y);
end

end