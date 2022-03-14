classdef checkdimsLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = checkdimsLayer(NVargs)
            arguments
                NVargs.Name string = "cd"
            end
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            Z = X;
        end
    end
    
end