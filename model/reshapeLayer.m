classdef reshapeLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        NewShapeArr
    end
    properties (Learnable)
    end
    methods
        function layer = reshapeLayer(name, NVargs)
            layer.Name = name;
            layer.NewShapeArr = NVargs.NewShapeArr;
        end
        function [Z] = predict(layer, X)
            if(size(layer.NewShapeArr)==3)
                Z = reshape(X,layer.NewShapeArr(1),layer.NewShapeArr(2),layer.NewShapeArr(3));
            end
            if (size(layer.NewShapeArr)==4)
                    Z = reshape(X,layer.NewShapeArr(1),layer.NewShapeArr(2),layer.NewShapeArr(3),layer.NewShapeArr(4));
            end
            
        end
    end
    
end