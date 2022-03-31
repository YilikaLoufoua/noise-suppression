classdef concatLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
    end
    properties (Learnable)
    end
    methods
        function layer = concatLayer(NVargs)
            arguments
                NVargs.Name string = "concat"
                NVargs.InputNames = []
            end
            layer.Name = NVargs.Name;
            layer.InputNames = NVargs.InputNames;
        end
        function Z = predict(layer, in1,in2)
            % Z = horzcat(in1,in2);
            Z = cat(4, in1, in2);
            % Z = cat(2,squeeze(in2),squeeze(in1));
        end
    end
    
end