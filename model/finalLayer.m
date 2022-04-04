classdef finalLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        timeSize
    end
    properties (Learnable)
    end
    methods
        function layer = finalLayer(timeSize,NVargs)
            arguments
                timeSize = 0
                NVargs.Name string = "final"
            end
            layer.timeSize = timeSize;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            formated = reshape(X, size(X,1),[],257,layer.timeSize);
            formated = formated(:,:,:,3:end);
            formated = dlarray(formated,"CBSS");
            Z = formated;
        end
    end
    
end