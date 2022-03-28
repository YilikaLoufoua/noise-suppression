classdef normLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        isSpecial
    end
    properties (Learnable)
    end
    methods
        function layer = normLayer(isSpecial, NVargs)
            arguments
                isSpecial = false
                NVargs.Name string = "norm"
            end
            layer.isSpecial = isSpecial;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            formated = X;
            % mean normalization
            mu = mean(formated,'all');
            normed = formated / (mu + 1e-5);
            if(layer.isSpecial)
                normed = stripdims(normed);
                % 257    32     1   313
                normed = permute(normed, [3,1,2,4]); %SCBT => BSCT  1   257    32   313
                normed = reshape(normed, [size(normed,1)*size(normed,2),size(normed,3),size(normed,4)]);
                normed = permute(normed, [1,3,2]); % BTC
                normed = dlarray(normed,'BTS'); %257 313 32
            end
            % max normalization
            % maxVal = max( X ,[], 'all' )+ 1e-5;
            % normed = X / maxVal;
            Z = normed;
        end
    end
    
end