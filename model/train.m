% Import clean audio dataset
dataFolder = "../datasets_fullband/clean_fullband";
adsTrain = audioDatastore(fullfile(dataFolder));
adsTrain = shuffle(adsTrain);
% Import noise dataset
noiseFolder = "../datasets_fullband/noise_fullband";
adsNoise = audioDatastore(fullfile(noiseFolder));
inputFs = 48e3;
fs = 8e3;
src = dsp.SampleRateConverter("InputSampleRate",inputFs, ...
                              "OutputSampleRate",fs, ...
                              "Bandwidth",7920);

noisyDS = transform(adsTrain,@(x)combineNC(x,adsNoise,src));
cleanDS = transform(adsTrain,@(x)preprocessClean(x,src));
combinedDS= combine(cleanDS,noisyDS);

% Define the layers of the network using fully connected layers
sigLength = 80000;
numF = 257;
FFTLength = 512;
win_length = 512;
overlap_length = 512-256;
numHiddenUnits_fb = 512;
numHiddenUnits_sb = 384;
layers = [
    imageInputLayer([sigLength 1],"Normalization","none")
    logSpectrogramLayer(sigLength,'Window',hamming(win_length,"periodic"),'FFTLength',FFTLength,...
        'OverlapLength',overlap_length)
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numF)
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
    'MiniBatchFcn',@preprocessMiniBatch);
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

% Loop over epochs.
for epoch = 1:numEpochs
    
    % Shuffle data.
    shuffle(mbq)
    
    % Loop over mini-batches
    while hasdata(mbq)
        
        iteration = iteration + 1;
        
        [dlX,dlY] = next(mbq);
                       
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function.
        [gradients,state,loss] = dlfeval(@modelGradients, dlnet, dlX, dlY);
        dlnet.State = state;
        
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