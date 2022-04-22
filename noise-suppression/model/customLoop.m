% Import clean audio dataset
dataFolder = "../datasets_fullband/clean_fullband";
adsTrain =audioDatastore(dataFolder,IncludesubFolders=true);

% Import noise dataset
noiseFolder = "../datasets_fullband/noise_fullband";
adsNoise = audioDatastore(noiseFolder,IncludesubFolders=true);

combinedDS = transform(adsTrain,@(x)HelperGenerateSpeechDenoisingFeatures(x,adsNoise));
% combinedDS = transform(combinedDS,@commonPreprocessing);


% Define the layers of the network using fully connected layers
numFeatures = 257;
FFTLength = 512;
win_length = 512;
overlap_length = 512-256;
numHiddenUnits_fb = 512;
numHiddenUnits_sb = 384;
numSegments = 8;

lgraph = layerGraph();
tempLayers = [sequenceInputLayer([numFeatures,numSegments],"Name","sequence_1")
                normLayer("Name","norm_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers= reshapeLayer(false,"Name","reshape_1");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    flattenLayer("Name","flatten")
    lstmLayer(numHiddenUnits_fb,"Name","lstm_1")
    lstmLayer(numHiddenUnits_fb,"Name","lstm_2")
    fullyConnectedLayer(numFeatures,"Name","fc_1")
    reluLayer("Name","relu")
    reshapeLayer(true, "Name","reshape_2")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    % concatLayer("InputNames", {'in1'  'in2'})
    concatenationLayer(2,2,"Name","concat")
    normLayer("Name","norm_3")
    flattenLayer("Name","flatten_2")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_3")
    lstmLayer(numHiddenUnits_sb,"Name","lstm_4")
    fullyConnectedLayer(numFeatures,"Name","fc_2")
    checkdimsLayer()];
lgraph = addLayers(lgraph,tempLayers);

% clean up helper variable
clear tempLayers;
lgraph = connectLayers(lgraph,"norm_1","reshape_1");
lgraph = connectLayers(lgraph,"norm_1","flatten");
lgraph = connectLayers(lgraph,"reshape_1","concat/in2");
lgraph = connectLayers(lgraph,"reshape_2","concat/in1");

% Specify the training options for the network.
miniBatchSize = 128;
options = trainingOptions("adam", ...
    MaxEpochs=3, ...
    InitialLearnRate=0.001,...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropFactor=0.9, ...
    LearnRateDropPeriod=1);

% Train the network
% denoiseNetFullyConnected = trainNetwork(combinedDS,layerGraph(layers),options);
dlnet = dlnetwork(lgraph);

numEpochs = 3;
plots = "training-progress";
mbq = minibatchqueue(combinedDS,...
'MiniBatchSize',miniBatchSize,...
'PartialMiniBatch','discard',...
'MiniBatchFormat',{'SCBT',''});

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