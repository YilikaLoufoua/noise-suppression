classdef relabelLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        first
        newLabel
    end
    properties (Learnable)
    end
    methods
        function layer = relabelLayer(first, newLabel, NVargs)
            arguments
                first = false
                newLabel string = ''
                NVargs.Name string = "relabel"
            end
            layer.first = first;
            layer.newLabel = newLabel;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            Z = X;
            if(layer.first)
             Z = reshape(Z, size(X, 1), [], 313);
            else 
                Z = reshape(Z, size(X,1), []);
            end
            Z = dlarray(Z, layer.newLabel);
        end
    end
    
end