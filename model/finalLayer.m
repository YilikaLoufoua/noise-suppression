classdef finalLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = finalLayer(NVargs)
            arguments
                NVargs.Name string = "final"
            end
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            formated = X(:,:,:,3:end);
            formated = dlarray(formated,"TBSC");
            Z = formated;
        end
    end
    
end