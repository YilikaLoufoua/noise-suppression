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
            % if(size(layer.NewShapeArr)==3)
            %     Z = reshape(X,layer.NewShapeArr(1),layer.NewShapeArr(2),layer.NewShapeArr(3));
           %  end
            % if (size(layer.NewShapeArr)==4)
            %         Z = reshape(X,layer.NewShapeArr(1),layer.NewShapeArr(2),layer.NewShapeArr(3),layer.NewShapeArr(4));
            % end
            formatedArr = X;
            if(layer.isIn1)
                 formatedArr = permute(formatedArr, [1,3,2,4]);
                % formatedArr = dlfeval(@permuteCross,X);
            end
            Z = dlarray(formatedArr,'SCBT');
            % Z = reshape(Z, [257,8,1]);
            
        end
    end
    
end


function formatedArr = permuteCross(input)
    formatedArr = extractdata(input);
    formatedArr = permute(formatedArr, [1,3,2,4]);
end