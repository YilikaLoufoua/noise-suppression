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
            % formated = reshape(size(X,1), 1,size(X,2),size(X,3));
            % formated = padarray(X, [0,0,0,2],0,'post');
            formated = extractdata(X);
            % formated = permute(formated, [3,2,1,4]);
            formated = padarray(formated, [0,2,0,0],0,'post');
            formated = dlarray(formated,'STB');
            Z = formated;
        end
    end
    
end