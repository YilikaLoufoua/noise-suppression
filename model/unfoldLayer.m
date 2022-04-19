classdef unfoldLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = unfoldLayer(NVargs)
            arguments
                NVargs.Name string = "unfoldLayer"
            end
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            num_neighbors=15;
            output = reshape(X,size(X,1), 1, size(X,2), size(X,3)); % SCBT  [257 1 5 94]
            [num_freqs,num_channels, batch_size, num_frames] = size(output);
            % SCBT => BCST
            output = permute(output, [3,2,1,4]);
            sub_band_unit_size = num_neighbors * 2 + 1;
            output = padarray(output,[0, 0, num_neighbors, 0],'symmetric','both');
            output = im2col_cus(output);
            output = reshape(output, [batch_size, num_channels, sub_band_unit_size, num_frames, num_freqs]);
            %  5     1    31    94   257
            output = permute(output,[1,5,2,3,4]);
            
            output = reshape(output, [batch_size, num_freqs, sub_band_unit_size, num_frames]);
            output = dlarray(output,'BSCT');
            Z = output;
        end
    end
    
end