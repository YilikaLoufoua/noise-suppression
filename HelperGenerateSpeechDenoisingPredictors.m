% Extracting predictor magnitude STFT from the audioDatastore
function predictors = HelperGenerateSpeechDenoisingPredictors(x, adsNoise, params)
    
    % Get system parameters for generating target signals
    win = params('win');
    overlap = params('overlap');
    ffTLength = params('ffTLength');
    inputFs = params('inputFs');
    fs = params('fs');
    numFeatures = params('numFeatures');

    % Select a random noise sample
    adsNoise = shuffle(adsNoise);
    noise = read(adsNoise);

    % Set the audio samples to a uniform length of 10 seconds
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

    % Create a sample rate converter to convert the 48 kHz audio to 8 kHz
    src = dsp.SampleRateConverter("InputSampleRate", params('inputFs'), ...
                              "OutputSampleRate", params('fs'), ...
                              "Bandwidth", params('Bandwidth'));

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

    % Generate magnitude STFT vectors from the noisy audio signal.
    noisySTFT = stft(noisyAudio,'Window',win,'OverlapLength',overlap,'FFTLength',ffTLength);
    noisySTFT = abs(noisySTFT(numFeatures-1:end,:));

    % Set the predictors.
    predictors = noisySTFT;
end