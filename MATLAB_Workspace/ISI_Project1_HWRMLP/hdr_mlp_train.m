function hdr_mlp_train(trainingDataSet, nHiddenLayer, nHiddenNeuron, functionType, learningRate, maxError)

% HDR_MLP_TRAIN Train a Multilayer Perceptron for solving the Handwritten Digit Recognition problem
%  HDR_MLP_TRAIN(...) generates a Multilayer Perceptron and trains it using
%  the backpropagation learning algorithm. The trained MLP performs a
%  pattern recognition task for solving the handwritten digit recognition
%  problem. 
%
%  During the training the total error along the epochs is plotted and
%  training only stops when the total error becomes lower than a given
%  threshold. If required the user can manually stop the training before
%  this condition comes true. At the end of the training, the entire
%  workspace is saved in a mat file
%
%  Inputs:
%     trainingDataSet - A cell array containing both the inputs and the
%                       desired outputs matrices
%     nHiddenLayer - The number of desired hidden layers in the MLP
%     nHiddenNeuron - An array with the number of neurons per hidden layer
%     functionType - An array with the selection (from pre-defined options)
%                    of activation function for each layer
%         functionType = 1 -> Logistic Function
%         functionType = 2 -> Hyperbolic Tangent
%     learningRate - Scale factor for the weight updates step size
%     maxError - Threshold value for stopping the training
%
%  Other m-files required: none
%  Subfunctions: activationFunction, derivativeFunction
%  MAT-files required: none
%
%  See also: HDR_MLP

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 11-September-2013

%% Process the inputs and generates global parameters

% input is a matrix containing all the input data for the entire training
% data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    N - Number of inputs per example
input = trainingDataSet{1};

% input is a matrix containing all the desired outputs for the entire 
% training data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    N - Number of outputs per example
output = trainingDataSet{2};

% nExample stores the total number of examples in the data set
% nInput stores the number of inputs per example
% nOutput stores the number of outputs per example
[nExample nInput] = size(input);
[~, nOutput] = size(output);

% nLayer contains the total number of layers in the neural network
nLayer = nHiddenLayer + 1;

% nNeuron is an array containing the number of neurons per layer
nNeuron = [nHiddenNeuron nOutput];

% outputFileName is a formated string containing the current date and time
outputFileName = sprintf('%s.mat', datestr(now,31));

%% Initialize the data structure used to represent the neural network

% neuronOut is a matrix that stores the output of each neuron in the 
% network in the current iteration of the learning algorithm. Each column
% of neuronOut represents one layer of neurons, except the first column,
% which represents the inputs. Therefore, the matrix dimensions are:
%    M - Max number of neurons in all layers
%        (for each column, only nNeuron(iLayer) contains valid data)
%    N - Number of layers + 1 (for the inputs)
neuronOut = zeros(max(nNeuron),nLayer+1);

% neuronSum is a matrix that stores the weighted sum of of the inputs for
% each neuron in the network in the current iteration of the learning
% algorithm. Each column of neuronSum represents one layer of neurons.
%    M - Max number of neurons in all layers
%        (for each column, only nNeuron(iLayer) contains valid data)
%    N - Number of layers
neuronSum = zeros(max(nNeuron),nLayer);

% neuronError is a matrix that stores the error of each neuron in the 
% network in the current iteration of the learning algorithm. Each column 
% of neuronError represents one layer of neurons.
%    M - Max number of neurons in all layers
%        (for each column, only nNeuron(iLayer) contains valid data)
%    N - Number of layers
neuronError = zeros(max(nNeuron),nLayer);

% weight is a cell array that stores all the weight matrices of the
% network. Each cell 'i' contains a matrix of dimensions:
%    M - number of neurons in the layer 'i'
%    N - number of neurons in the layer 'i-1' + 1 (for the bias)
%    (for the first layer of neurons, N = number of inputs)
% deltaWeight is a cell array the stores the weight updates for one
% iteration of the learning algorithm. It has the same dimensions of weight
weight = cell(1,nLayer);
deltaWeight = cell(1,nLayer);
for iLayer = 1:nLayer
    if iLayer == 1
        N = nInput+1;
    else
        N = nNeuron(iLayer-1)+1;
    end
    weight{iLayer} = rand(nNeuron(iLayer),N)*(2.0/N) - (1.0/N);
    deltaWeight{iLayer} = zeros(nNeuron(iLayer),N);
end

%% Initialize the performance measurement variables

% totalError is the cumulated error throughout an entire epoch
% (it's initialized with a high value just to enter the while loop)
epochError = maxError + 1;

% networkError stores the progression of epochError (used for plotting)
% (networkError is initialized with maxEpochs slots in order to make the
% program more efficient during the first epochs. If the number of epochs
% exceeds maxEpochs the program starts losing performance)
maxEpochs = 10000;
networkError = zeros(1,maxEpochs);

% Epoch counter
iEpoch = 1;

% User request stop training command
stopTraining = 0;

%% Print all parameters on screen before training the network

disp('\nFunction HDR_MLP_train\n\n');
disp('Starting to train the Multilayer Perceptron with the parameters:\n');
fprintf('\t Number of layers: %d', nLayer);
fprintf('\t Number of neurons per layer: [ ');
for iLayer = 1:nLayer
    fprintf('%d ',nNeuron(iLayer));
end
fprintf('] \n');
fprintf('\t Selected activation functions:\n');
for iLayer = 1:nLayer
    if(nNeuron(iLayer) == 1)
        fprintf('\t\t Layer %d: Sigmoid\n',nNeuron(iLayer));
    else
        fprintf('\t\t Layer %d: Hyperbolic Tangent (scaled to [0,1])\n',nNeuron(iLayer));
    end
end
fprintf('\t Learning rate: %f\n', learningRate);
fprintf('\t Stopping condition: Epoch error < %f\n',maxError);
fprintf('\n Once the network is trained it will be saved to the file %s\n', outputFileName);

%% Prepare a figure for displaying the progression of epochError

errorFigure = figure;
uicontrol('style','push','string','Stop Training','callback','stopTraining = 1');
% place other commands here related to the graph presentation

%% Learning loop

while(epochError > maxError && ~stopTraining)
    
    % Clear the totalError at the beginning of the epoch
    epochError = 0;
    
    % Iterate through all the examples of the training data set 
    for iExample = 1:nExample
        
        % Initialize the first column of neuronOut with the inputs
        neuronOut(:,1) = input(iExample,:)';
        
        % Calculate the sum and output for each neuron of each layer
        for iLayer = 1:nLayer
            neuronSum(:,iLayer) = weight{iLayer} * [neuronOut(:,iLayer) ; 1];
            neuronOut(:,iLayer+1) = activationFunction(neuronSum, functionType(iLayer));
        end
        
        % Calculate the error of the final layer of neurons and
        % backpropagate it to the entire network
        for iLayer = nLayer:-1:1
            if(iLayer == nLayer)
                neuronError(:,iLayer) = (output(iExample,:)' - neuronOut(:,iLayer+1)) * derivativeFunction(neuronOut, functionType(iLayer));
            else
                neuronError(:,iLayer) = weight{iLayer+1}(:,1:nNeuron(iLayer)) * neuronError(:,iLayer+1) * derivativeFunction(neuronOut, functionType(iLayer));
            end
            
            % Calculate the weight updates 
            deltaWeight{iLayer} = deltaWeight{iLayer} + neuronError(:,iLayer) * [neuronOut(:,iLayer) ; 1]';
        end
        
        % If in on-line mode, process the weight updates after each example
        if(onlineMode)
            for iLayer = 1:nLayer
                weight{iLayer} = weight{iLayer} + deltaWeight{iLayer} * learningRate;
                deltaWeight{iLayer} = zeros(size(deltaWeight{iLayer}));
            end
        end
        
        % Adds the current quadratic error in the epochError variable
        epochError = epochError + sum((output(iExample)' - neuronOut(:,nLayer+1)).^2);
        
    end
    
    % If in batch mode, process the weight updates at the end of the epoch
    if(~onlineMode)
        for iLayer = 1:nLayer
            weight{iLayer} = weight{iLayer} + deltaWeight{iLayer} * learningRate;
            deltaWeight{iLayer} = zeros(size(deltaWeight{iLayer}));
        end
    end
        
    % Store the current value of epochError for plotting
    networkError(iEpoch) = epochError;
    
    % Increase the epoch counter
    iEpoch = iEpoch + 1;
    
    % Update the networkError graph
    figure(errorFigure);
    plot(networkError);
    
end

%% Store the generated network and its parameters in an external file

save(outputFileName, 'weight', 'networkError', 'iEpoch', 'trainingDataSet', 'nLayer', 'nNeuron', 'functionType', 'learningRate', 'maxError');



function outputArray = activationFunction(inputArray, functionType)
% Generates an output array by aplying the selected function to the input
% array. functionType determines which type of function should be applied.

switch(functionType)
    
    % Logistic Function
    case 1
        outputArray = 1/(1 + exp(-inputArray));
        
    % Hyerbolic Tangent (scaled to [0,1]
    otherwise
        outputArray = 0.5 * (1 + tanh(inputArray));
end

function outputArray = derivativeFunction(inputArray, functionType)
% Generates an output array by aplying the selected function to the input
% array. functionType determines which type of function should be applied.
% The selected function is the derivative of the corresponding function at
% the activationFunction subfunction.

switch(functionType)
    
    % Derivative of Logistic Function
    case 1
        outputArray = inputArray .* (1 - inputArray);
        
    % Derivative of Hyerbolic Tangent (scaled to [0,1])
    otherwise
        outputArray = 0.5 * sech(inputArray).^2;
end
