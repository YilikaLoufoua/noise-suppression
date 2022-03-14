classdef reshapeLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        isIn1
    end
    properties (Learnable)
    end
    methods
        function layer = reshapeLayer(isIn1, NVargs)
            arguments
                isIn1 = false
                NVargs.Name string = "reshape"
            end
            layer.Name = NVargs.Name;
            layer.isIn1 = isIn1;
        end
        function Z = predict(layer, X)
            formatedArr = X;
            Z = X;
            % special manupulation of input1 size to be ready for concat
            % layer
            if(layer.isIn1)
                sizeArr = size(X);
                formatedArr = reshape(formatedArr, [sizeArr(1),1,sizeArr(2),1]);
                Z = dlarray(formatedArr,'SCBT');
                 % formatedArr = permute(formatedArr, [1,3,2,4]);
                % formatedArr = dlfeval(@permuteCross,X);
            end 
            % Z = reshape(Z, [257,8,1]);
            
            
        end
    end
    
end
