classdef relabelLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        timeSize
        newLabel
    end
    properties (Learnable)
    end
    methods
        function layer = relabelLayer(timeSize, newLabel, NVargs)
            arguments
                timeSize = 0
                newLabel string = ''
                NVargs.Name string = "relabel"
            end
            layer.timeSize = timeSize;
            layer.newLabel = newLabel;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            Z = X;
             Z = reshape(Z, size(X, 1), [], layer.timeSize);
            Z = dlarray(Z, layer.newLabel);
            % [32, 1285, 94]  'CBT'
        end
    end
    
end