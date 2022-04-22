classdef padLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = padLayer(NVargs)
            arguments
                NVargs.Name string = "pad"
            end
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            formated = extractdata(X);
            formated = padarray(formated, [0,2,0,0],0,'post');
            maxVal = max( formated ,[], 'all' )+ 1e-5;
            formated = formated / maxVal;
            formated = dlarray(formated,'STB');

            Z = formated;
        end
    end
    
end