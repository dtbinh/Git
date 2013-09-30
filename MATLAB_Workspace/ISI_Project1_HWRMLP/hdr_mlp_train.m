function hdr_mlp_train(dataSet, nHiddenNeuron, functionType, learningRate, onlineMode, stoppingCondition, outputFolder)

% HDR_MLP_TRAIN Train a Multilayer Perceptron for solving the Handwritten Digit Recognition problem
%  HDR_MLP_TRAIN(...) generates a Multilayer Perceptron and trains it using
%  the backpropagation learning algorithm. The trained MLP performs a
%  pattern recognition task for solving the handwritten digit recognition
%  problem. 
%
%  During the training the cummulative quadratic error and the 
%  misclassification rate along the epochs are plotted. Training stops when
%  the quadratic error reaches a treshold or the maximum number of epochs
%  is reached. If required, the user can manually stop the training. At the 
%  end of the training, the trained network is saved to a mat file.
%
%  Inputs:
%     trainingDataSet - A cell array containing both the inputs and the
%                       desired outputs matrices
%     nHiddenLayer - The number of desired hidden layers in the MLP
%     nHiddenNeuron - An array with the number of neurons per hidden layer
%     functionType - An array with the selection (from pre-defined options)
%                    of activation function for each layer
%         functionType = 1 -> Linear Function
%         functionType = 2 -> Logistic Function
%         functionType = 3 -> Hyperbolic Tangent
%     learningRate - Scale factor for the weight updates step size
%     onlineMode - A flag to indicate if the weights should be updated
%     after each example or only at the end of the epoch
%     stoppingCondition - A cell array containing the following parameters
%        * maxEpochError
%        * maxEpoch
%
%  Training Stop Condition:
%    The network training is stopped when one or more of the following
%    conditions becomes true:
%      * When the cumulated quadratic error throughout an entire epoch is 
%        smaller than maxEpochError;
%      * After the number of epochs reaches maxEpoch
%
%
%  Other m-files required: neuronActivationFunction.m,
%  neuronDerivativeFunction.m
%  Subfunctions: none
%  MAT-files required: none
%
%  See also: HDR_MLP, HDR_MLP_TEST, LOADDATASET, NEURONACTIVATIONFUNCTION,
%  NEURONDERIVATIVEFUNCTION

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 22-September-2013

%% Global variables
%  The variables described here are global and can be accessed from Matlab
%  main terminal. The description of each variable can be found later in
%  the code where the variable is initialized.
global stopTraining pauseTraining;

%% Process the inputs and generates main parameters

% input is a matrix containing all the input data for the entire training
% data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    N - Number of inputs per example
input = dataSet{1};

% input is a matrix containing all the desired outputs for the entire 
% training data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    N - Number of outputs per example
output = dataSet{2};

% nDataSet is the size of the dataSet parameter. If nDataSet is greater
% than 2, it means that not only the training data set is present but there
% is also a validation data set available
[~, nDataSet] = size(dataSet);
if(nDataSet > 2)
    validationDataSet = 1;
    validationInput = dataSet{3};
    validationOutput = dataSet{4};
else
    validationDataSet = 0;
end

% nExample stores the total number of examples in the training data set
% nValidationExample stores the total number of examples in the validation
% data set
% nInput stores the number of inputs per example
% nOutput stores the number of outputs per example
[nExample nInput] = size(input);
[nValidationExample ~] = size(validationInput);
[~, nOutput] = size(output);

% nNeuron is an array containing the number of neurons per layer
% nLayer contains the total number of layers in the neural network
nNeuron = [nHiddenNeuron nOutput];
[~, nHiddenLayer] = size(nHiddenNeuron);
nLayer = nHiddenLayer + 1;

% maxEpochError
maxValidationMissRate = stoppingCondition{1};

% maxEpochs
maxEpoch = stoppingCondition{2};

% outputFileName is a formated string containing the current date and time
outputFileName = sprintf('networks/%s/%s.mat', outputFolder, datestr(now,30));

%% Initialize the data structure used to represent the neural network

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
    if(iLayer == 1)
        N = nInput+1;
    else
        N = nNeuron(iLayer-1)+1;
    end
    wscale = 0.1 / N;
    weight{iLayer} = rand(nNeuron(iLayer), N) * 2*wscale - wscale;
    deltaWeight{iLayer} = zeros(nNeuron(iLayer), N);
end

%% Initialize the performance measurement variables

% epochError is the cumulated quadratic error throughout an entire epoch
epochError = 0;

% epochMissrate is the total number of times the network fails to classify
% an input correctly throughout an entire epoch
epochMissRate = 0;

% networkError stores the progression of epochError 
networkError = zeros(1,maxEpoch);

% networkMissRate stores the progression of epochMissRate
networkMissRate = zeros(1,maxEpoch);

% validationError stores the progression of epochError when measured in the
% validation data set
validationError = zeros(1,maxEpoch);

% validationmissRate stores the progression of epochError when measured in 
% the validation data set
validationMissRate = zeros(1,maxEpoch);

% Loop flag - It becomes 1 when the stopping condition is reached or the
% user manually requests the program to stop
stopTraining = 0;

% Pause flag - User request flag that allows pausing the training algorithm
% for analyzing global variables
pauseTraining = 0;

programPaused = 0;

%% Print all parameters on screen before training the network

fprintf('\nFunction HDR_MLP_train\n\n');
fprintf('Starting to train the Multilayer Perceptron with the parameters:\n');
fprintf('\t Number of layers: %d\n', nLayer);
fprintf('\t Number of neurons per layer: [ ');
for iLayer = 1:nLayer
    fprintf('%d ',nNeuron(iLayer));
end
fprintf('] \n');
fprintf('\t Selected activation functions:\n');
for iLayer = 1:nLayer
    if(functionType(iLayer) == 1)
        fprintf('\t\t Layer %d: Linear Function\n',iLayer);
    elseif(functionType(iLayer) == 2)
        fprintf('\t\t Layer %d: Logistic Function\n',iLayer);
    elseif(functionType(iLayer) == 3)
        fprintf('\t\t Layer %d: Hyperbolic Tangent (scaled to [0,1])\n',iLayer);    
    else
        fprintf('\t\t Layer %d: Hyperbolic Tangent ([-1,1])\n',iLayer);
    end
end
fprintf('\t Learning rate: %f\n', learningRate);
if(onlineMode)
    fprintf('\t Weight update mode:  Online Mode\n');
else
    fprintf('\t Weight update mode:  Batch Mode\n');
end
fprintf('\n Once the network is trained it will be saved to the file %s\n', outputFileName);

%% Prepare a figure for displaying the progression of the network performance

errorFigure = figure;
pauseButton = uicontrol('style','push', 'Position', [110 5 100 25], 'string','Pause Training','callback','global pauseTraining; pauseTraining = 1 - pauseTraining;');
stopButton = uicontrol('style','push', 'Position', [360 5 100 25], 'string','Stop Training','callback','global stopTraining; stopTraining = 1;');

%% Learning loop

timeStart = tic;
for iEpoch = 1:maxEpoch
    
    % Clear the error variables at the beginning of the epoch
    epochError = 0;
    epochMissRate = 0;
    
    % Iterate through all the examples of the training data set 
    for iExample = 1:nExample
        
        % Initialize the first column of neuronOut with the inputs
        neuronOut{1} = input(iExample,:)';
        
        % Calculate the sum and output for each neuron of each layer
        for iLayer = 1:nLayer
            neuronSum{iLayer} = weight{iLayer} * [neuronOut{iLayer} ; 1];
            neuronOut{iLayer+1} = neuronActivationFunction(neuronSum{iLayer}, functionType(iLayer));
        end
        
        % Calculate the error of the final layer of neurons and
        % backpropagate it to the entire network
        for iLayer = nLayer:-1:1
            if(iLayer == nLayer)
                neuronError{iLayer} = (output(iExample,:)' - neuronOut{iLayer+1});
            else
                neuronError{iLayer} = weight{iLayer+1}(:,1:nNeuron(iLayer))' * (neuronError{iLayer+1} .* neuronDerivativeFunction(neuronOut{iLayer+2}, functionType(iLayer+1)));
            end
            
            % Calculate the weight updates 
            deltaWeight{iLayer} = deltaWeight{iLayer} + neuronError{iLayer} .* neuronDerivativeFunction(neuronOut{iLayer+1}, functionType(iLayer)) * [neuronOut{iLayer} ; 1]';
        end
        
        % If in on-line mode, process the weight updates after each example
        if(onlineMode)
            for iLayer = 1:nLayer
                weight{iLayer} = weight{iLayer} + learningRate * deltaWeight{iLayer};
                deltaWeight{iLayer} = zeros(size(deltaWeight{iLayer}));
            end
        end
        
        % Adds the current quadratic error in the epochError variable
        epochError = epochError + sum((output(iExample,:)' - neuronOut{nLayer+1}).^2);
        
        % Verify if the network has correctly classifie this example        
        [~, correctClass] = max(output(iExample,:));
        [~, networkClass] = max(neuronOut{nLayer+1});
        if(networkClass ~= correctClass)
            epochMissRate = epochMissRate + 1.0;
        end
    end
    
    % If in batch mode, process the weight updates at the end of the epoch
    if(~onlineMode)
        for iLayer = 1:nLayer
            weight{iLayer} = weight{iLayer} + learningRate * deltaWeight{iLayer};
            deltaWeight{iLayer} = zeros(size(deltaWeight{iLayer}));
        end
    end

    % Store the current value of epochError and epochMissRate for plotting
    networkError(iEpoch) = epochError / nExample;
    networkMissRate(iEpoch) = epochMissRate / nExample;
    
    % If a validation data set is present, evaluate the current performance
    % of the network in it
    if(validationDataSet)
        
        % Clear the error variables at the beginning of the epoch
        epochError = 0;
        epochMissRate = 0;
        
        % Iterate through all the examples of the training data set
        for iExample = 1:nValidationExample
            
            % Initialize the first column of neuronOut with the inputs
            neuronOut{1} = validationInput(iExample,:)';
            
            % Calculate the sum and output for each neuron of each layer
            for iLayer = 1:nLayer
                neuronSum{iLayer} = weight{iLayer} * [neuronOut{iLayer} ; 1];
                neuronOut{iLayer+1} = neuronActivationFunction(neuronSum{iLayer}, functionType(iLayer));
            end
            
            % Adds the current quadratic error in the epochError variable
            epochError = epochError + sum((validationOutput(iExample,:)' - neuronOut{nLayer+1}).^2);
            
            % Verify if the network has correctly classifie this example
            [~, correctClass] = max(validationOutput(iExample,:));
            [~, networkClass] = max(neuronOut{nLayer+1});
            if(networkClass ~= correctClass)
                epochMissRate = epochMissRate + 1.0;
            end
        end
        
        % Store the current value of validationError and validationMissRate
        % for plotting
        validationError(iEpoch) = epochError / nValidationExample;
        validationMissRate(iEpoch) = epochMissRate / nValidationExample;
        
        if(validationMissRate < maxValidationMissRate)
            stopTraining = 1;
        end
    end
    
    % Pause program execution, if a pauseTraining has been requested
    while(pauseTraining)
        set(pauseButton, 'string', 'Resume Training');
        programPaused = 1;
        pause(0.1);
    end
    
    if(programPaused)
        set(pauseButton, 'string', 'Pause Training');
        programPaused = 0;
    end
    
    % Update the networkError and networkMissRate graphs
    if(mod(iEpoch,300) == 0)
        figure(errorFigure)
        subplot(1,2,1); 
        hold off; plot(networkError(1:iEpoch), '-b');
        hold on;  plot(validationError(1:iEpoch), '-r');
        subplot(1,2,2); 
        hold off; plot(networkMissRate(1:iEpoch), '-b');
        hold on;  plot(validationMissRate(1:iEpoch), '-r');
    end
    
    % Stop program execution, if a stopTraining has been requested
    if(stopTraining)
        break;
    end
    
end
elapsedTime = toc(timeStart);

%% Store the generated network and its parameters in an external file

save(outputFileName, 'weight', 'elapsedTime', 'iEpoch', 'networkError', 'networkMissRate', 'validationError', 'validationMissRate', 'nLayer', 'nNeuron', 'functionType', 'learningRate', 'onlineMode');

