classdef relabelLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        newLabel
    end
    properties (Learnable)
    end
    methods
        function layer = relabelLayer(newLabel, NVargs)
            arguments
                newLabel string = ''
                NVargs.Name string = "relabel"
            end
            layer.newLabel = newLabel;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            Z = dlarray(X, layer.newLabel);
        end
    end
    
end