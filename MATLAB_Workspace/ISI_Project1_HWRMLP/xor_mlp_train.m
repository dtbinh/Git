function xor_mlp_train(trainingDataSet, nHiddenLayer, nHiddenNeuron, functionType, learningRate, onlineMode)


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
outputFileName = sprintf('networks/%s.mat', datestr(now,30));

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
w = cell(1,nLayer);
dw = cell(1,nLayer);

for iLayer = 1:nLayer
    if(iLayer == 1)
        N = nInput+1;
    else
        N = nNeuron(iLayer-1)+1;
    end
%     wscale = (0.1 / 100) / 8;
    wscale = (1.0 / N) / 10.0;
    w{iLayer} = rand(nNeuron(iLayer), N) * 2*wscale - wscale;
    dw{iLayer} = zeros(nNeuron(iLayer), N);
end

%% Initialize the performance measurement variables

% epochError is the cumulated error throughout an entire epoch
epochError = 0;

% epochMissrate is the total number of times the network fails to classify
% an input correctly throughout an entire epoch
epochMissRate = 0;

% networkError stores the progression of epochError 
% networkMissRate stores the progression of epochMissRate
% (both arrays are initialized with maxEpochs slots in order to make the 
% program more efficient during the first epochs. If the number of epochs 
% exceeds maxEpochs the program starts losing performance)
maxEpochs = 10000;
networkError = zeros(1,maxEpochs);
networkMissRate = zeros(1,maxEpochs);

% Epoch counter
iEpoch = 0;

% Loop flag - It becomes 1 when the stopping condition is reached or the
% user manually requests the program to stop
stopTraining = 0;

% Pause flag - User request flag that allows pausing the training algorithm
% for analyzing global variables
pauseTraining = 0;

%% Print all parameters on screen before training the network

%% Prepare a figure for displaying the progression of the network performance
errorFigure = figure;
% uicontrol('style','push','string','Pause','callback','global pauseTraining; pauseTraining = 1 - pauseTraining;');
uicontrol('style','push','string','Stop','callback','global stopTraining; stopTraining = 1;');

%% Learning loop

while(~stopTraining)

    % Increase the epoch counter
    iEpoch = iEpoch + 1;
    
    %%%%DEBUG
    fprintf('Starting Epoch: \t%d\n',iEpoch);
    
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
        
%         fprintf('Calculating the final Layer for the example %d\n', iExample);
%         INPUTS = [neuronOut{2} ; 1]'
%         WEIGHTS = w{2}
%         S2 = neuronSum{2}
%         OUT2 = neuronOut{2+1}
        
        % Calculate the error of the final layer of neurons and
        % backpropagate it to the entire network
        for iLayer = nLayer:-1:1
            if(iLayer == 2)
                neuronError{iLayer} = (output(iExample,:)' - neuronOut{iLayer+1});
            else
                neuronError{iLayer} = w{iLayer+1}(:,1:nNeuron(iLayer))' * (neuronError{iLayer+1} .* derivativeFunction(neuronOut{iLayer+2}, functionType(iLayer+1)));
            end
            
            % Calculate the weight updates 
            dw{iLayer} = dw{iLayer} + neuronError{iLayer} .* derivativeFunction(neuronOut{iLayer+1}, functionType(iLayer)) * [neuronOut{iLayer} ; 1]';
        end
        
        % If in on-line mode, process the weight updates after each example
        if(onlineMode)
            for iLayer = 1:nLayer
                w{iLayer} = w{iLayer} + learningRate * dw{iLayer};
                dw{iLayer} = zeros(size(dw{iLayer}));
            end
        end
        
        % Adds the current quadratic error in the epochError variable
        epochError = epochError + sum((output(iExample,:)' - neuronOut{nLayer+1}).^2);
        
        % Verify if the network has correctly classifie this example        
        [~, correctClass] = max(output(iExample,:));
        [~, networkClass] = max(neuronOut{nLayer+1});
        if(networkClass ~= correctClass)
            epochMissRate = epochMissRate + 1.0;
%             fprintf('Example %d: FAIL\n', iExample);
%             OUT = output(iExample,:)
%             Y2 = neuronOut{nLayer+1}'
%             fprintf('CorrectClass = %d; NetworkClass = %d\n\n\n', correctClass, networkClass);
        else
%             fprintf('Example %d: SUCCESS\n', iExample);
        end

%         pauseTraining = 1;
        

%         if(output(iExample,1) > 0.5 && neuronOut{nLayer+1} < 0.5)
%             epochMissRate = epochMissRate + 1.0;
%         elseif(output(iExample,1) < 0.5 && neuronOut{nLayer+1} > 0.5)
%             epochMissRate = epochMissRate + 1.0;
%         end

        
%         if(output(iExample,1) > output(iExample,2))
%             if(neuronOut{nLayer+1}(1) < neuronOut{nLayer+1}(2))
%                 epochMissRate = epochMissRate + 1.0;  
%                 fprintf('Example %d failed!\n', iExample);
%                 fprintf('Output = %f %f ; Network = %f %f\n', output(iExample,1), output(iExample,2), neuronOut{nLayer+1}(1), neuronOut{nLayer+1}(2));
% %                 INPUTS = neuronOut{1}'
% %                 S1 = neuronSum{1}'
% %                 L1 = neuronOut{2}'
% %                 S2 = neuronSum{2}'
% %                 L2 = neuronOut{3}'
% %                 pauseTraining = 1;
%             end
%         else
%             if(neuronOut{nLayer+1}(1) > neuronOut{nLayer+1}(2))
%                 epochMissRate = epochMissRate + 1.0;  
%                 fprintf('Example %d failed!\n', iExample);
%                 fprintf('Output = %f %f ; Network = %f %f\n', output(iExample,1), output(iExample,2), neuronOut{nLayer+1}(1), neuronOut{nLayer+1}(2));
% %                 INPUTS = neuronOut{1}'
% %                 S1 = neuronSum{1}'
% %                 L1 = neuronOut{2}'
% %                 S2 = neuronSum{2}'
% %                 L2 = neuronOut{3}'
% %                 pauseTraining = 1;
%             end
%         end
        
        while(pauseTraining)
            pause(0.1);
        end
        
        
    end
    
    % If in batch mode, process the weight updates at the end of the epoch
    if(~onlineMode)
        for iLayer = 1:nLayer
            w{iLayer} = w{iLayer} + learningRate * dw{iLayer};
            dw{iLayer} = zeros(size(dw{iLayer}));
        end
    end

    % Store the current value of epochError and epochMissRate for plotting
    networkError(iEpoch) = epochError;
    networkMissRate(iEpoch) = epochMissRate / nExample;
    
    % Update the networkError and networkMissRate graphs
    if(mod(iEpoch,10) == 0)
        figure(errorFigure)
        subplot(1,2,1); plot(networkError(1:iEpoch));
        subplot(1,2,2); plot(networkMissRate(1:iEpoch)); ylim([0 1]);
    end
    
    % Pause the program execution at the end of the Epoch, if the user has
    % requested for it    
    while(pauseTraining)
        pause(0.1);
    end
    
end

%% Store the generated network and its parameters in an external file

save(outputFileName, 'trainingDataSet', 'nHiddenLayer', 'nHiddenNeuron', 'functionType', 'w');


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
        

function outputArray = derivativeFunction(inputArray, functionType)
% Generates an output array by aplying the selected function to the input
% array. functionType determines which type of function should be applied.
% The selected function is the derivative of the corresponding function at
% the activationFunction subfunction.

switch(functionType)
        
    % Linear
    case 1
        outputArray = ones(size(inputArray));
    
    % Logistic Function
    case 2
        outputArray = (inputArray .* (1-inputArray));
        
    % Hyerbolic Tangent (scaled to [0,1]
    otherwise
        outputArray = 0.5 .* sech(inputArray) .* sech(inputArray);
end


