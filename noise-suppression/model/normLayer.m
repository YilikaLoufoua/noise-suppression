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
            normed = stripdims(X);
            % mean normalization
            % mu = mean(formated,'all');
            % normed = formated / (mu + 1e-5);
            if(layer.isSpecial)
                normed = permute(normed, [1,2,4,3]);
                means = mean(normed,[1,2,3]);
                newNormed = normed ./ (means + 1e-5);
                normed = permute(newNormed, [4,1,2,3]);
                normed = reshape(normed, [size(normed,1)*size(normed,2),size(normed,3),size(normed,4)]);
                % 1285 32 94   TCU   BU
                % normed = permute(normed, [1,3,2]); 
                normed = dlarray(normed,'TCU'); 
            else
                normed = permute(normed, [1,3,2]);
                means = mean(normed,[1,2]);
                newNormed = normed ./ (means+ 1e-5);
                normed = dlarray(newNormed,'STB');
            end
    
            Z = normed;
        end
    end
    
end