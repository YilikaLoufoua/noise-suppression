% Define a function for extracting the target and predictor magnitude STFT from the tall table
function [targets, predictors] = HelperGenerateSpeechDenoisingFeatures(x, adsNoise, src)
    
    % Define system parameters for generating target and predictor signals
    windowLength = 256;
    win = hamming(windowLength,"periodic");
    overlap = round(0.75 * windowLength);
    ffTLength = windowLength;
    inputFs = 48e3;
    fs = 8e3;
    numFeatures = ffTLength/2 + 1;
    numSegments = 8;
    
    % Select a random noise sample
    adsNoise = shuffle(adsNoise);
    noise = read(adsNoise);

    % Set the audio samples to uniform length of 10 seconds
    inputFs = 48000;
    expected_length = 10;
    if length(x) > expected_length * inputFs
        x = x(1:expected_length * inputFs);
    else
        blankSignal = zeros(expected_length * inputFs - length(x),1);
        x = [x; blankSignal];
    end
    
    if length(noise) > expected_length * inputFs
        noise = noise(1:expected_length * inputFs);
    else
        blankSignal = zeros(expected_length * inputFs - length(noise),1);
        noise = [noise; blankSignal];
    end

    % Make the singal lengths a multiple of the sample rate converter decimation factor.
    decimationFactor = inputFs/fs;
    L = floor(numel(x)/decimationFactor);
    x = x(1:decimationFactor*L);
    noise = noise(1:decimationFactor*L);

    % Downsample the signals
    x = src(x);
    reset(src);
    noise = src(noise);
    reset(src);
    
    % Set the noise power such that the signal-to-noise ratio (SNR) is zero dB
    speechPower = sum(x.^2);
    noisePower = sum(noise.^2);
    noisyAudio = x + sqrt(speechPower/noisePower) * noise;
    
    % Generate magnitude STFT vectors from the original and noisy audio signals.
    cleanSTFT = stft(x,'Window',win,'OverlapLength',overlap,'FFTLength',ffTLength);
    cleanSTFT = abs(cleanSTFT(numFeatures-1:end,:));
    noisySTFT = stft(noisyAudio,'Window',win,'OverlapLength',overlap,'FFTLength',ffTLength);
    noisySTFT = abs(noisySTFT(numFeatures-1:end,:));
    
    % Generate the 8-segment training predictor signals from the noisy STFT.
    noisySTFT = [noisySTFT(:,1:numSegments - 1), noisySTFT];
    stftSegments = zeros(numFeatures, numSegments , size(noisySTFT,2) - numSegments + 1);
    for index = 1:size(noisySTFT,2) - numSegments + 1
        stftSegments(:,:,index) = (noisySTFT(:,index:index + numSegments - 1)); 
    end
    
    % Set the targets and predictors.
    targets = cleanSTFT;
    predictors = stftSegments;
end