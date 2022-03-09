% Import clean audio dataset
dataFolder = "../datasets_fullband/clean_fullband";
adsTrain =audioDatastore(dataFolder,IncludesubFolders=true);

% Import noise dataset
noiseFolder = "../datasets_fullband/noise_fullband";
adsNoise = audioDatastore(noiseFolder,IncludesubFolders=true);

combinedDS = transform(adsTrain,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));
% combinedDS = transform(combinedDS,@commonPreprocessing);


% Define the layers of the network using fully connected layers
sigLength = 80000;
numF = 257;
FFTLength = 512;
win_length = 512;
overlap_length = 512-256;
numHiddenUnits_fb = 512;
numHiddenUnits_sb = 384;


numFeatures = 257;
numSegments = 8;
layers = [
    imageInputLayer([numFeatures,numSegments],"Normalization","none")
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numFeatures)
    ];

% Specify the training options for the network.
miniBatchSize = 10;
options = trainingOptions("adam", ...
    "MaxEpochs",3, ...
    "InitialLearnRate",1e-5,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...
    "Plots","training-progress", ...
    "Verbose",false, ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",1);

% Train the network
% denoiseNetFullyConnected = trainNetwork(combinedDS,layerGraph(layers),options);
lgraph = layerGraph(layers);
dlnet = dlnetwork(lgraph);

numEpochs = 3;
plots = "training-progress";
mbq = minibatchqueue(combinedDS,...
'MiniBatchSize',miniBatchSize,...
'PartialMiniBatch','discard',...
'MiniBatchFormat',{'SSBC',''});

if plots == "training-progress"
    figure
    lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
    ylim([0 inf])
    xlabel("Iteration")
    ylabel("Loss")
    grid on
end
trailingAvg = [];
trailingAvgSq = [];
iteration = 0;
start = tic;
training = "training......";

% Loop over epochs.
for epoch = 1:numEpochs
    training
    % Shuffle data.
    shuffle(mbq)
    
    % Loop over mini-batches
    while hasdata(mbq)
        
        iteration = iteration + 1;
        
        [dlX, dlY] = next(mbq);
        % dlX = miniBatch(:,1,:);
        % dlY = miniBatch(:,2,:);
                       
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function.
        [gradients,loss] = dlfeval(@modelGradients, dlnet, dlX, dlY);
        
        % Update the network parameters using the Adam optimizer.
        [dlnet,trailingAvg,trailingAvgSq] = adamupdate(dlnet,gradients, ...
            trailingAvg,trailingAvgSq,iteration);
        
        % Display the training progress.
        if plots == "training-progress"
            D = duration(0,0,toc(start),'Format','hh:mm:ss');
            addpoints(lineLossTrain,iteration,double(gather(extractdata(loss))))
            title("Epoch: " + epoch + ", Elapsed: " + string(D))
            drawnow
        end
    end
end

function [gradients,loss] = modelGradients(dlnet,dlX,Y)
    dlYPred = forward(dlnet,dlX);    
    loss = crossentropy(dlYPred,Y);    
    gradients = dlgradient(loss,dlnet.Learnables);
    
end


function [X,Y] = preprocessMiniBatch(Cell)
    X = Cell{2}(:,1);
    Y = Cell{1}(:,1);
end

function dataOut = commonPreprocessing(data)
    dataOut = cell(size(data));
end