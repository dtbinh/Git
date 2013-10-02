function resultCell = hdr_mlp_test(networkFile, dataSetFile, controlVariable)

% HDR_MLP_TEST  Test the MLP networks trained with hdr_mlp_train
%    resultCell = HDR_MLP_TEST(networkFile, dataSetFile, controlVariable)
%    opens the trained network stored in the networkFile and test it using
%    the dataSetFile. The neural network should have been generated
%    by the function hdr_mlp_train, so that all the network fields match 
%    the ones used in this function. The returned resultCell is a cell 
%    array cointaining the network average quadratic error, the  
%    misclassification rate and a third variable selected by the parameter
%    controlVariable. The parameter controlVariable must assume one of the
%    options described below.
%
%    Possible options for 'controlVariable'
%    --------------------------------------
%
%    controlVariable           resultCell{1}
%    ---------------           -------------
%    learningRate          ->  learningRate
%    learningRateLog       ->  log10(learningRate)
%    nNeuron               ->  nNeuron(nLayer-1)
%    nNeuron2              ->  nNeuron(nLayer-1) + 100*nNeuron(nLayer-2)
%    activationFunction    ->  functionType(nLayer)
%    activationFunction2   ->  functionType(nLayer) + 10*functionType(nLayer-1)
%    2D_nNeuron            ->  {nNeuron(nLayer-2) nNeuron(nLayer-1)}
%    2D_activationFunction ->  {functionType(nLayer-1) functionType(nLayer)}
%
%
%  Other m-files required: loadDataSet.m
%  Subfunctions: none
%  MAT-files required: <networkFile>
%
%  See also: HDR_MLP_TRAIN, HDR_MLP_TEST_ALL, HDR_MLP_TEST_ALL_2D

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 30-September-2013

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

% Express the network error and miss rate in percentage values
networkError = networkError / nExample;
networkMissRate = networkMissRate / nExample;

%% Produce the test result cell array

% Initialize the result cell array
resultCell = cell(1,3);

% Select the control variable based on the provided parameter
if(strcmp(controlVariable, 'iEpoch'))
    resultCell{1} = network.iEpoch;
elseif(strcmp(controlVariable, 'learningRate'))
    resultCell{1} = network.learningRate;
elseif(strcmp(controlVariable, 'learningRateLog'))
    resultCell{1} = log10(network.learningRate);
elseif(strcmp(controlVariable, 'nNeuron'))
    resultCell{1} = network.nNeuron(nLayer-1);
elseif(strcmp(controlVariable, 'nNeuron2'))
    resultCell{1} = network.nNeuron(nLayer-1) + 100*network.nNeuron(nLayer-2);
elseif(strcmp(controlVariable, 'activationFunction'))
    resultCell{1} = network.functionType(nLayer-1);
elseif(strcmp(controlVariable, 'activationFunction2'))
    resultCell{1} = network.functionType(nLayer) + 10*network.functionType(nLayer-1);    
elseif(strcmp(controlVariable, '2D_nNeuron'))
    resultCell{1} = cell(1,2);
    resultCell{1}{1} = network.nNeuron(nLayer-2);
    resultCell{1}{2} = network.nNeuron(nLayer-1);
elseif(strcmp(controlVariable, '2D_activationFunction'))
    resultCell{1} = cell(1,2);
    resultCell{1}{1} = network.functionType(nLayer-1);
    resultCell{1}{2} = network.functionType(nLayer);
end

% Copy the error and the miss rate into the result cell array
resultCell{2} = networkError;
resultCell{3} = networkMissRate;