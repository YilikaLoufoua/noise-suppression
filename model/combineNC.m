function predictor  = combineNC(x,adsNoise,src)

    % Define system parameters for generating target and predictor signals
    fs = 8e3;

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

    predictor = noisyAudio;
    
end

