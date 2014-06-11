function needleTrackerTrain(trainingFile, validationFile, trainingFunction, hiddenLayers, functionType, learningRate, maxEpoch, outputFolder)

%
% FUNCTION DESCRIPTION
%

%% Create and configure the network

% Initialize the network setting the training method and the number of
% neurons in the hidden layers
net = feedforwardnet(hiddenLayers, trainingFunction);

% Divide the training dataset into training and validation
% net.divideParam.trainRatio = trainRatio;
% net.divideParam.valRatio = 1 - trainRatio;

% Set the activation function for each layer
nLayer = size(hiddenLayers, 2) + 1;

for iLayer = 1:nLayer
    net.layers{iLayer}.transferFcn = functionType{iLayer};
end

% Set the learning rate
net.trainParam.lr = learningRate;

% Set the training stopping conditions
net.trainparam.epochs = double(maxEpoch);
net.trainParam.min_grad = 0;
net.trainParam.time = inf;
net.trainParam.max_fail = intmax;

% Output file
mkdir(sprintf('networks/%s', outputFolder));
outputFileName = sprintf('networks/%s/%s.mat', outputFolder, datestr(now,30));


%% Print all parameters on screen before training the network

fprintf('\nFunction needleTracker_train\n\n');
fprintf('Starting to train the Multilayer Perceptron with the parameters:\n');
fprintf('\t Number of layers: %d\n', nLayer);
fprintf('\t Number of neurons per layer: [ ');
for iLayer = 1:nLayer
    fprintf('%d ',net.layers{iLayer}.size);
end
fprintf('] \n');
fprintf('\t Selected activation functions:\n');
for iLayer = 1:nLayer
    fprintf('\t\t Layer %d: %s\n',iLayer, net.layers{iLayer}.transferFcn);
end
% fprintf('\t Training dataset split into: %d%% training - %d%% validation', 100*trainRatio, 100*(1-trainRatio));
fprintf('\t Learning rate: %f\n', learningRate);
fprintf('\t Maximum number of epochs: %f\n', maxEpoch);
fprintf('\n Once the network is trained it will be saved to the file %s\n', outputFileName);


%% Train the network using the training dataset

% Read the training dataset
trainingDataSet = load(trainingFile);
trainingInput = trainingDataSet.inputMatrix;
trainingOutput = trainingDataSet.outputMatrix;

% Shuffle the training dataset
nInput = size(trainingInput, 1);
nOutput = size(trainingOutput, 1);
trainingDataSetMatrix = [trainingInput ; trainingOutput];
trainingDataSetMatrix = unsortMatrix(trainingDataSetMatrix, 'c');
trainingInput = trainingDataSetMatrix(1:nInput,:);
trainingOutput = trainingDataSetMatrix(nInput+1:nInput+nOutput,:);

% Read the validation dataset
validationDataSet = load(validationFile);
validationInput = validationDataSet.inputMatrix;
validationOutput = validationDataSet.outputMatrix;

% Combine the training and validation datasets
input = [trainingInput validationInput];
output = [trainingOutput validationOutput];

% Set the trainRation apriopriately
trainRatio = size(trainingInput,2) / (size(trainingInput,2) + size(validationInput,2));
net.divideFcn = 'divideblock';
net.divideParam.trainRatio = trainRatio;
net.divideParam.valRatio = 1 - trainRatio;
net.divideParam.testRatio = 0;

% Train the network
[net,tr] = train(net, input, output);
figure;
plotperform(tr);

%% Saved the trained network

save(outputFileName);
