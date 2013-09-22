function xor_mlp_test1(trainingDataSet, nHiddenLayer, nHiddenNeuron, functionType, w)

%% Process the inputs and generates main parameters

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

% neuronOut is a cell array that stores the output of each neuron in the 
% network in the current iteration of the learning algorithm. Each cell 'i'
% represents one layer of the network, except the first one, which 
% represents the inputs.
neuronOut = cell(1,nLayer+1);

% neuronSum is a cell array that stores the weighted sum of of the inputs
% for each neuron in the network in the current iteration of the learning
% algorithm. Each cell 'i' represents one layer of neurons.
neuronSum = cell(1,nLayer);

% neuronError is a cell array that stores the error of each neuron in the 
% network in the current iteration of the learning algorithm. Each cell 'i' 
% represents one layer of neurons.
neuronError = cell(1,nLayer);

neuronOut{1} = zeros(nInput,1);
for iLayer = 1:nLayer
    neuronOut{iLayer+1} = zeros(nNeuron(iLayer),1);
    neuronSum{iLayer} = zeros(nNeuron(iLayer),1);
    neuronError{iLayer} = zeros(nNeuron(iLayer),1);    
end

% Clear the error variables at the beginning of the epoch
epochError = 0;
epochMissRate = 0;

% Iterate through all the examples of the training data set
for iExample = 1:nExample
    
    % Initialize the first column of neuronOut with the inputs
    neuronOut{1} = input(iExample,:)';
    
    % Calculate the sum and output for each neuron of each layer
    neuronSum{1} = w{1} * [neuronOut{1} ; 1];
    neuronOut{1+1} = activationFunction(neuronSum{1}, functionType(1));
    
    neuronSum{2} = w{2} * [neuronOut{2} ; 1];
    neuronOut{2+1} = activationFunction(neuronSum{2}, functionType(2));
    
    % Adds the current quadratic error in the epochError variable
    epochError = epochError + sum((output(iExample,:)' - neuronOut{nLayer+1}).^2);
    
    % Verify if the network has correctly classifie this example
    [~, correctClass] = max(output(iExample,:));
    [~, networkClass] = max(neuronOut{nLayer+1});
    if(networkClass ~= correctClass)
        epochMissRate = epochMissRate + 1.0;
    end
end

networkError = epochError
networkMissRate = epochMissRate / nExample
    

function outputArray = activationFunction(inputArray, functionType)
% Generates an output array by aplying the selected function to the input
% array. functionType determines which type of function should be applied.

switch(functionType)
        
    % Linear
    case 1
        outputArray = inputArray;
    
    % Logistic Function
    case 2
        outputArray = 1.0 ./ (1+exp(-inputArray));
        
    % Hyerbolic Tangent (scaled to [0,1]
    otherwise
        outputArray = 0.5 * (1 + tanh(inputArray));
end