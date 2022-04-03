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
            formated = reshape(X, size(X,1),[],257,313);
            formated = formated(:,:,:,3:end);
            formated = dlarray(formated,"CBSS");
            Z = formated;
        end
    end
    
end