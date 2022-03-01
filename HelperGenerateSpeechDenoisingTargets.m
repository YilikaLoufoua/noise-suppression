% Extracting target magnitude STFT from the audioDatastore
function targets = HelperGenerateSpeechDenoisingTargets(x, params)
    
    % Get system parameters for generating target signals
    win = params('win');
    overlap = params('overlap');
    ffTLength = params('ffTLength');
    inputFs = params('inputFs');
    fs = params('fs');
    numFeatures = params('numFeatures');
    
    % Set the audio sample to a uniform length of 10 seconds
    expected_length = 10;
    if length(x) > expected_length * inputFs
        x = x(1:expected_length * inputFs);
    else
        blankSignal = zeros(expected_length * inputFs - length(x),1);
        x = [x; blankSignal];
    end

    % Create a sample rate converter to convert the 48 kHz audio to 8 kHz
    src = dsp.SampleRateConverter("InputSampleRate", params('inputFs'), ...
                              "OutputSampleRate", params('fs'), ...
                              "Bandwidth", params('Bandwidth'));

    % Make the singal length a multiple of the sample rate converter decimation factor.
    decimationFactor = inputFs/fs;
    L = floor(numel(x)/decimationFactor);
    x = x(1:decimationFactor*L);

    % Downsample the signal
    x = src(x);
    reset(src);

    % Generate magnitude STFT vectors from the original and noisy audio signals.
    cleanSTFT = stft(x,'Window',win,'OverlapLength',overlap,'FFTLength',ffTLength);
    cleanSTFT = abs(cleanSTFT(numFeatures-1:end,:));

    % Set the targets.
    targets = cleanSTFT;
end
