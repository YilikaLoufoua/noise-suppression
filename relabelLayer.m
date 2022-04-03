classdef relabelLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        first
        timeSize
        newLabel
    end
    properties (Learnable)
    end
    methods
        function layer = relabelLayer(first, timeSize, newLabel, NVargs)
            arguments
                first = false
                timeSize = 0
                newLabel string = ''
                NVargs.Name string = "relabel"
            end
            layer.first = first;
            layer.timeSize = timeSize;
            layer.newLabel = newLabel;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            Z = X;
            if(layer.first)
             Z = reshape(Z, size(X, 1), [], layer.timeSize);
            else 
                Z = reshape(Z, size(X,1), []);
            end
            Z = dlarray(Z, layer.newLabel);
        end
    end
    
end