classdef reshapeRDLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        newDims
        newLabel
    end
    properties (Learnable)
    end
    methods
        function layer = reshapeRDLayer(newDims, newLabel,NVargs)
            arguments
                newDims = []
                newLabel string = ''
                NVargs.Name string = "reshape"
            end
            layer.newDims = newDims;
            layer.newLabel = newLabel;
            layer.Name = NVargs.Name;
        end
        function Z = predict(layer, X)
            newDimen = layer.newDims;
            if(isempty(newDimen))
                newDimen = size(X);
            end
            newLab = layer.newLabel;
            if(newLab == "")
                newLab = dims(X);
            end
            formatedArr = X;
            formatedArr = reshape(formatedArr, newDimen);
            Z = dlarray(formatedArr,newLab);          
        end
    end
    
end