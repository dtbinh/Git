function [networkMissRate networkError] = hdr_mlp_test(networkFile, dataSetFile)

% HDR_MLP_TEST 
%  [error missRate] = hdr_mlp_test(networkFile, dataSetFile) tests the
%  trained neural network stored in the networkFile using the data set
%  stored in the dataSetFile. The neural network should have been generated
%  by the function hdr_mlp_train, so that all the network fields match the
%  ones used in this function. The returned values are the cummulative
%  quadratic error of the network and the network miss rate, in respect to
%  the handwritten digit recognition problem.
%
%  Other m-files required: loadDataSet.m
%  Subfunctions: none
%  MAT-files required: <networkFile>
%
%  See also: HDR_MLP_TRAIN, LOADDATASET

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 22-September-2013

%% Import data from the input files

% Load the trained neural network from networkFile. All the network
% important parameters are copied to local variables in order to simplify
% usage.
network = load(networkFile);
nLayer = network.nLayer;
nNeuron = network.nNeuron;
functionType = network.functionType;
weight = network.weight;

% Load the data set that will be used to test the trained neural network.
dataSet = loadDataSet(dataSetFile);
input = dataSet{1};
output = dataSet{2};
[nExample nInput] = size(input);

%% Build the neural network basic structure

neuronOut = cell(1,nLayer+1);
neuronSum = cell(1,nLayer);
neuronOut{1} = zeros(nInput,1);
for iLayer = 1:nLayer
    neuronOut{iLayer+1} = zeros(nNeuron(iLayer),1);
    neuronSum{iLayer} = zeros(nNeuron(iLayer),1);
end

%% Test the neural network

% Prepare the error variables
networkError = 0;
networkMissRate = 0;

% Iterate through all the examples of the data set
for iExample = 1:nExample
    
    % Initialize the first column of neuronOut with the inputs
    neuronOut{1} = input(iExample,:)';
    
    % Calculate the sum and output for each neuron of each layer
    for iLayer = 1:nLayer
        neuronSum{iLayer} = weight{iLayer} * [neuronOut{iLayer} ; 1];
        neuronOut{iLayer+1} = neuronActivationFunction(neuronSum{iLayer}, functionType(iLayer));
    end
    
    % Adds the current quadratic error in the error variable
    networkError = networkError + sum((output(iExample,:)' - neuronOut{nLayer+1}).^2);
    
    % Verify if the network has correctly classified this example
    [~, correctClass] = max(output(iExample,:));
    [~, networkClass] = max(neuronOut{nLayer+1});
    if(networkClass ~= correctClass)
        networkMissRate = networkMissRate + 1.0;
    end
end

% Convert the network miss rate to a percentage value
networkMissRate = networkMissRate / nExample;
    
