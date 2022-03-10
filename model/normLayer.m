classdef normLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = normLayer(NVargs)
            arguments
                NVargs.Name string = "norm"
            end
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            mu = mean(X,'all');
            normed = X / (mu + 1e-5);
            Z = normed;
        end
    end
    
end