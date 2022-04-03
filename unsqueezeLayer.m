classdef unsqueezeLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        indexNum
    end
    properties (Learnable)
    end
    methods
        function layer = unsqueezeLayer(indexNum, NVargs)
            arguments
                indexNum = 2
                NVargs.Name string = "pad"
            end
            layer.indexNum = indexNum;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            switch layer.indexNum
               case 1
                  formated = reshape(X,1,size(X,1), size(X,2),size(X,3));
               case 2
                  formated = reshape(X,size(X,1), 1,size(X,2),size(X,3));
               case 3
                  formated = reshape(X,size(X,1), size(X,2),1,size(X,3));
                case 4
                  formated = reshape(X,size(X,1), size(X,2),size(X,3),1);
               otherwise
                  formated = X;
            end
            formated = dlarray(formated, "SCBT");
            Z = formated;
        end
    end
    
end