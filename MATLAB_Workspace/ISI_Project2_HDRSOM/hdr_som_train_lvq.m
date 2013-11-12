function hdr_som_train_lvq(mapFile, dataSet, learningParameters, maxEpoch)

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
updateRate = 1;

% Load the self-organized map from mapFile. 
mapStruct = load(mapFile);
map = mapStruct.map;
mapLabel = mapStruct.mapLabel;
mapSize = mapStruct.mapSize;

% input is a matrix containing all the input data for the entire training
% data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    N - Number of inputs per example
input = dataSet{1};

% output is a matrix containing the desired output for each example of the
% training data set. The matrix dimensions are:
%    M - Number of examples in the data set
%    1 - Number of outputs per example
output = dataSet{2};

% nDataSet is the size of the dataSet parameter. If nDataSet is greater
% than 2, it means that not only the training data set is present but there
% is also a validation data set available
nDataSet = size(dataSet,2);

% validationDataSet is a boolean flag indicating if a validation data set
% is available
% validationInput is a matrix containing all the input data for the entire  
% validation data set
% validationOutput is a matrix containing all the desired outputs for the   
% entire validation data set
if(nDataSet > 2)
    validationDataSet = 1;
    validationInput = dataSet{3};
    validationOutput = dataSet{4};
else
    validationDataSet = 0;
end

% nInput stores the number of inputs per example
% nExample stores the total number of examples in the training data set
[nExample nInput] = size(input);

% L0 is the initial value of the learning rate L (ranging from 0 to 1). It
% is initialized as a ratio Lratio of the last used value of L during the
% training of the self-organizing map
Lratio = learningParameters{1};
L0 = Lratio * mapStruct.L0*exp(-double((mapStruct.iEpoch-1))/mapStruct.tauL);

% tauL is the time constant associated to the decrease of L. It is
% calculated so that L becomes L0/100 at iEpoch = learningParameter{2}
tauLratio = learningParameters{2};
tauL = tauLratio * mapStruct.tauL;
            
% outputFileName is the name of the file to which the map will be saved
% once the training is over. It is a formated string containing a flag
% outputFolder and the current date and time
outputFileName = sprintf('LVQ-%s', mapFile);


%% Initialize the data structure used to represent the self-organizing map

% inputVector is 1x1xnInput vector for parsing each example of the data set
inputVector = zeros(1, 1, nInput);


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
fprintf('\t Learning Rate: L = %f * exp(-t / %f)\n', L0, tauL);
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
    L = L0*exp(-double((iEpoch-1))/tauL);
    
    % Store the values of L for plotting
    learningRate(iEpoch) = L;
    
    % For each example of the training data set:
    for iExample = 1:nExample
        
        % Retrieve the current example and parse it into inputVector
        inputVector(1,1,:) = input(iExample,:);
        
        % Compute the euclidian distance between the each neuron an the input
        distance = sqrt(sum((map-repmat(inputVector,mapSize)).^2, 3));
        
        % Find the closest neuron to the input
        [r c] = find(distance == min(min(distance)));
        
        % Compare the classes of the example and the wining neuron
        if(mapLabel(r(1), c(1)) == output(iExample))
            % Move the wining neuron closer to the example
            map(r(1), c(1), :) = map(r(1), c(1), :) + L*(inputVector(1,1,:)- map(r(1), c(1), :));
        else
            % Move the wining neuron appart from the example
            map(r(1), c(1), :) = map(r(1), c(1), :) - L*(inputVector(1,1,:)- map(r(1), c(1), :));
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

totalTrainingTime = elapsedTime + mapStruct.elapsedTime;
totalTrainingEpoch = iEpoch + mapStruct.iEpoch;

totalNetworkError = [mapStruct.networkError networkError];
totalNetworkMissRate = [mapStruct.networkMissRate networkMissRate];

totalValidationError = [mapStruct.validationError validationError];
totalValidationMissRate = [mapStruct.validationMissRate validationMissRate];

save(outputFileName, 'map', 'mapLabel', 'newMapLabel', 'totalTrainingTime', 'totalTrainingEpoch', 'totalNetworkError', 'totalNetworkMissRate', 'totalValidationError', 'totalValidationMissRate', 'mapSize', 'Lratio', 'L0', 'tauLratio', 'tauL');