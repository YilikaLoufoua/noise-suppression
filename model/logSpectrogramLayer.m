classdef logSpectrogramLayer < nnet.layer.Layer
    % Example custom log spectrogram layer.
    
    properties
        % (Optional) Layer properties.
        % Spectral window
        Window
        % Number of overlapped smaples
        OverlapLength
        % Number of DFT points
        FFTLength
        % Signal Length
        SignalLength
    end
    
    methods
        function layer = logSpectrogramLayer(sigLength,NVargs)
            arguments
                sigLength {mustBeNumeric}
                NVargs.Window {mustBeFloat,mustBeNonempty,mustBeFinite,mustBeReal,mustBeVector}= hann(128,'periodic')
                NVargs.OverlapLength {mustBeNumeric} = 96
                NVargs.FFTLength {mustBeNumeric} = 128
                NVargs.Name string = "logspec"
            end
            layer.Type = 'logSpectrogram';
            layer.Name =  NVargs.Name;
            layer.SignalLength = sigLength;
            layer.Window = NVargs.Window;
            layer.OverlapLength = NVargs.OverlapLength;
            layer.FFTLength = NVargs.FFTLength;

            % Validate input parameters are valid
            validateInput(layer)     
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer at prediction time and
            % output the result.
            %
            % Inputs:
            %         layer - Layer to forward propagate through
            %         X     - Input data, specified as a 1-by-1-by-C-by-N 
            %                 dlarray, where N is the mini-batch size.
            % Outputs:
            %         Z     - Output of layer forward function returned as 
            %                 an sz(1)-by-sz(2)-by-sz(3)-by-N dlarray,
            %                 where sz is the layer output size and N is
            %                 the mini-batch size.
            
            % Use dlstft to compute short-time Fourier transform.
            % Specify the data format as SSCB to match the output of 
            % imageInputLayer.
            
            X = squeeze(X);                      
            [YR,YI] = dlstft(X,'Window',layer.Window,...
                'FFTLength',layer.FFTLength,'OverlapLength',layer.OverlapLength,...
                'DataFormat','TBC');
            
            % This code is needed to handle the fact that 2D convolutional
            % DAG networks expect SSCB
            YR = permute(YR,[1 4 2 3]);
            YI = permute(YI,[1 4 2 3]);
            
            
            % Take the logarithmic squared magnitude of short-time Fourier
            % transform.
            Z = log(YR.^2 + YI.^2);
        end
        
        % We do not need to implement the backward function becasue all the
        % operations we use in predict function support dlarray. The
        % backward propagation can be done auotomatically.
        
        % We do not need to implement the forward function because our
        % layer uses the same forward pass for training and prediction
        % (inference).
        
        
        function validateInput(layer)
            % This function is only for use in the "Spoken Digit Recognition with
            % Custom Log Spectrogram Layer and Deep Learning" example. It may change or
            % be removed in a future release.

            % Get window length and validate
            nwin = length(layer.Window);
            validateattributes(nwin,{'numeric'},{'scalar','integer',...
                'nonnegative','real','nonnan','nonempty','finite','>',1},...
                'dlstft','WindowLength');

            % Check the number of samples is greater than the window length
            if nwin > layer.SignalLength
                coder.internal.error('signal:stft:InvalidWindowLength',nwin);
            end

            % Validate OverlapLength
            validateattributes(layer.OverlapLength,{'numeric'},...
                {'scalar','integer','nonnegative','real','nonnan',...
                'finite','nonempty','>=',0,'<',nwin},...
                'dlstft','OverlapLength');

            % Validate FFTLength
            validateattributes(layer.FFTLength,{'numeric'},...
                {'scalar','integer','nonnegative','real','nonnan',...
                'finite','nonempty','>=',nwin},'dlstft','FFTLength');
        end
    end
end

