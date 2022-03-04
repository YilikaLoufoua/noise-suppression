function target = preprocessClean(x, src)
    % Define system parameters for generating target and predictor signals
    fs = 8e3;

    % Set the audio samples to uniform length of 10 seconds
    inputFs = 48000;
    expected_length = 10;
    if length(x) > expected_length * inputFs
        x = x(1:expected_length * inputFs);
    else
        blankSignal = zeros(expected_length * inputFs - length(x),1);
        x = [x; blankSignal];
    end
   
    % Make the singal lengths a multiple of the sample rate converter decimation factor.
    decimationFactor = inputFs/fs;
    L = floor(numel(x)/decimationFactor);
    x = x(1:decimationFactor*L);

    % Downsample the signals
    x = src(x);
    reset(src);

    target = x;
end

