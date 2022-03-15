classdef reshapeLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = reshapeLayer(NVargs)
            arguments
                NVargs.Name string = "reshape"
            end
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            formatedArr = X;
            % special manupulation of input1 size to be ready for concat
            % layer
            sizeArr = size(X);
            formatedArr = reshape(formatedArr, [sizeArr(1),1,sizeArr(2),1]);
            Z = dlarray(formatedArr,'SCBT');
             % formatedArr = permute(formatedArr, [1,3,2,4]);
            % formatedArr = dlfeval(@permuteCross,X);
            % Z = reshape(Z, [257,8,1]);
            
            
        end
    end
    
end
