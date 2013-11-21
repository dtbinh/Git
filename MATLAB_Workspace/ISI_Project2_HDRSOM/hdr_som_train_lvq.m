function hdr_som_train_lvq(mapFile, learningParameters, maxEpoch)

%
% FUNCTION DESCRIPTION
%

%% Global variables
%  The variables described here are global and can be accessed from Matlab
%  main terminal. The description of each variable can be found later in
%  the code where the variable is initialized.
global stopTraining pauseTraining;

%% Process the inputs and generates main parameters

% [hard-coded parameter] updateRate
% The performance graphs are updated every updateRate epochs
updateRate = 10;

% Load the self-organized map from mapFile. 
mapStruct = load(mapFile);
map = mapStruct.map;
mapLabel = mapStruct.mapLabel;
mapSize = mapStruct.mapSize;

% input is a matrix containing all the input data for the entire training
% data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    N - Number of inputs per example
input = mapStruct.input;

% output is a matrix containing the desired output for each example of the
% training data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    1 - Number of outputs per example
output = mapStruct.output;

% validationInput is a matrix containing all the input data for the entire  
% validation data set
% validationOutput is a matrix containing all the desired outputs for the   
% entire validation data set
if(mapStruct.validationDataSet)
    validationDataSet = 1;
    validationInput = mapStruct.validationInput;
    validationOutput = mapStruct.validationOutput;
end

% nInput stores the number of inputs per example
% nExample stores the total number of examples in the training data set
[nExample nInput] = size(input);

% L0 is the initial value of the learning rate L (ranging from 0 to 1)
L0 = learningParameters{1};

% Lf is the final value of the learning rate (L(maxEpoch) = Lf)
Lf = learningParameters{2};

% tauL is the time constant associated to the decrease of L. 
tauL = (Lf-L0)/maxEpoch;
            
% outputFileName is the name of the file to which the map will be saved
% once the training is over. It is a formated string containing a flag
% outputFolder and the current date and time
outputFileName = sprintf('LVQ-%s', mapFile);


%% Initialize the performance measurement variables

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

% networkError stores the progression of epochError 
learningRate = zeros(1,maxEpoch);

% Loop flag - It becomes 1 when the stopping condition is reached or the
% user manually requests the program to stop
stopTraining = 0;

% Pause flag - User request flag that allows pausing the training algorithm
% for analyzing global variables
pauseTraining = 0;

% programPaused is a flag that becomes 1 after the program is paused. It is
% used to update pauseButton string after the program is unpaused
programPaused = 0;

%% Print all parameters on screen before training the network

fprintf('\nFunction HDR_SOM_LVQ\n\n');
fprintf('Optimizing the trained Self-Organizing Map with the parameters:\n');
fprintf('\t Map Size: %d\n', mapStruct.mapSize);
fprintf('\t Learning Rate: L = %f * (%f)*t\n', L0, tauL);
fprintf('\n Once the map is trained it will be saved to the file %s\n', outputFileName);

%% Prepare a figure for displaying the progression of the network performance

errorFigure = figure;
pauseButton = uicontrol('style','push', 'Position', [110 5 100 25], 'string','Pause Training','callback','global pauseTraining; pauseTraining = 1 - pauseTraining;');
stopButton = uicontrol('style','push', 'Position', [360 5 100 25], 'string','Stop Training','callback','global stopTraining; stopTraining = 1;');

%% Learning loop

% Save the starting time, for measuring the duration of the training
timeStart = tic;

% For each epoch:
for iEpoch = 1:maxEpoch  
    
    % Update the value of L
    L = L0 + tauL*double(iEpoch-1);
    
    % Store the values of L for plotting
    learningRate(iEpoch) = L;
    
    % For each example of the training data set:
    for iExample = 1:nExample
        
        % Compute the difference vectors between the input and each neuron
        % in the map
        differenceVector = repmat(reshape(input(iExample,:), [1 1 nInput]), mapSize) - map;
        
        % Compute the euclidian distance between the each neuron an the input
        distance = sqrt(sum((differenceVector).^2, 3));        
        
        % Find the closest neuron to the input
        [r c] = find(distance == min(min(distance)));
        
        % Compare the classes of the example and the wining neuron
        if(mapLabel(r(1), c(1)) == output(iExample))
            
            % Move the wining neuron closer to the example
            map(r(1), c(1), :) = map(r(1), c(1), :) + L * differenceVector(r(1), c(1), :);            
        else
            
            % Move the wining neuron appart from the example
            map(r(1), c(1), :) = map(r(1), c(1), :) - L * differenceVector(r(1), c(1), :);            
        end
    end
    
    % Measure the current map's performance in the training data set
    [error missRate] = testMap(map, mapLabel, input, output);
    networkError(iEpoch) = error;
    networkMissRate(iEpoch) = missRate;
    
    % Measure the current map's performance in the validation data set
    if(validationDataSet)
        [error missRate] = testMap(map, mapLabel, validationInput, validationOutput);
        validationError(iEpoch) = error;
        validationMissRate(iEpoch) = missRate;
    end
    
    % Update the networkError and networkMissRate graphs
    if(mod(iEpoch, updateRate) == 0)
        figure(errorFigure)
        subplot(1,3,1); 
        hold off; plot(networkError(1:iEpoch), '-b');
        hold on;  plot(validationError(1:iEpoch), '-r');
        subplot(1,3,2); 
        hold off; plot(networkMissRate(1:iEpoch), '-b');
        hold on;  plot(validationMissRate(1:iEpoch), '-r');
        subplot(1,3,3); 
        plot(learningRate(1:iEpoch));
    end    
    
    % Pause program execution, if a pauseTraining has been requested
    while(pauseTraining)
        set(pauseButton, 'string', 'Resume Training');
        programPaused = 1;
        pause(0.1);
    end
    
    % If unpausing, update the pauseButton string changin it back to "Pause
    % Training"
    if(programPaused)
        set(pauseButton, 'string', 'Pause Training');
        programPaused = 0;
    end    
    
    % Stop program execution, if a stopTraining has been requested
    if(stopTraining)
        break;
    end    
    
end
elapsedTime = toc(timeStart);
fprintf('End of LVQ optimization! Total time = %f\n', elapsedTime);

newMapLabel = labelMap(map, input, output);

%% Store the generated map and its parameters in an external file

save(outputFileName);