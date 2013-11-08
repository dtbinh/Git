function hdr_som_train(dataSet, mapSize, learningParameters, maxEpoch, outputFolder)

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

% L0 is the initial value of the learning rate L (ranging from 0 to 1)
L0 = learningParameters{1};

% N0 i the initial value of the size of the neighborhood N around the
% wining neuron, within which all neurons should be updated. It is given as
% a fraction of mapSize.
N0 = floor(learningParameters{2}*mapSize/2);

% tauL is the time constant associated to the decrease of L. It is
% calculated so that L becomes L0/100 at iEpoch = learningParameter{3}
tauL = learningParameters{3} / log(100);

% tauL is the time constant associated to the decrease of N. It is
% calculated so that N becomes 0 at iEpoch = learningParameter{4}
tauN = learningParameters{4} / log(double(2*N0));            
            
% outputFileName is the name of the file to which the map will be saved
% once the training is over. It is a formated string containing a flag
% outputFolder and the current date and time
outputFileName = sprintf('maps/%s/%s.mat', outputFolder, datestr(now,30));


%% Initialize the data structure used to represent the self-organizing map

% wScale is a scale factor for initializing all the weights of the
% self-organizing map. It is calculated as 1 per default
wScale = 1;

% map is a 3D matriz reprsenting all the weights of the self-organizing
% map. It can be seen as a MxM matriz where each element is a 1xN array of
% weights (M = mapSize and N = nInput). It is initialized with random
% values rangin from -wScale to wScale.
map = rand(mapSize, mapSize, nInput) * 2*wScale - wScale;

% mapLabel is a matrix containing the label of each neuron in map. It is a
% mapSize x mapSize matrix and it is generated using the labelMap function.
mapLabel = zeros(mapSize, mapSize);

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

% networkMissRate stores the progression of epochMissRate
neighborhoodSize = zeros(1,maxEpoch);

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

fprintf('\nFunction HDR_SOM_train\n\n');
fprintf('Starting to train the Self-Organizing Map with the parameters:\n');
fprintf('\t Map Size: %d\n', mapSize);
fprintf('\t Learning Rate: L = %f * exp(-t / %f)\n', L0, tauL);
fprintf('\t Neighboorhood Size: N = %f * exp(-t / %f)\n', N0, tauN);
fprintf('\n Once the network is trained it will be saved to the file %s\n', outputFileName);

%% Prepare a figure for displaying the progression of the network performance

errorFigure = figure;
pauseButton = uicontrol('style','push', 'Position', [110 5 100 25], 'string','Pause Training','callback','global pauseTraining; pauseTraining = 1 - pauseTraining;');
stopButton = uicontrol('style','push', 'Position', [360 5 100 25], 'string','Stop Training','callback','global stopTraining; stopTraining = 1;');

%% Learning loop

% Save the starting time, for measuring the duration of the training
timeStart = tic;

% For each epoch:
for iEpoch = 1:maxEpoch
    
    % QUESTION: Which equation to use
    t = double((iEpoch-1));
%     t = double((iEpoch-1)+(double(iExample-1))/nExample);
    
    % Update the values of L and N
    L = L0*exp(-t/tauL);
    N = round(N0*exp(-t/tauN));
    
    % Store the values of L and N for plotting
    learningRate(iEpoch) = L;
    neighborhoodSize(iEpoch) = N;
    
    % For each example of the training data set:
    for iExample = 1:nExample
        
        % Retrieve the current example and parse it into inputVector
        inputVector(1,1,:) = input(iExample,:);
        
        % Compute the euclidian distance between the each neuron an the input
        distance = sqrt(sum((map-repmat(inputVector,mapSize)).^2, 3));
        
        % Find the closest neuron to the input
        [r c] = find(distance == min(min(distance)));
        
        % Update the weight of all neurons within a neighborhood of width 2*N+1
        % centered in the wining neuron (r(1), c(1))
        rmin = max(1      , r(1)-N);
        rmax = min(mapSize, r(1)+N);
        for i = rmin:rmax
            cmin = max(1      , c(1)-N);
            cmax = min(mapSize, c(1)+N);
            for j = cmin:cmax
                
                % Update the neuron weight
                map(i,j,:) = map(i,j,:) + L * (inputVector(1,1,:) - map(i,j,:));
                
            end
        end
        
    end
    
    % At the end of the epoch, label the current map
    mapLabel = labelMap(map, input, output);
    
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
        subplot(2,3,[1 4]); 
        hold off; plot(networkError(1:iEpoch), '-b');
        hold on;  plot(validationError(1:iEpoch), '-r');
        subplot(2,3,[2 5]); 
        hold off; plot(networkMissRate(1:iEpoch), '-b');
        hold on;  plot(validationMissRate(1:iEpoch), '-r');
        subplot(2,3,3); 
        plot(learningRate(1:iEpoch));
        subplot(2,3,6); 
        plot(neighborhoodSize(1:iEpoch));
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

%% Store the generated map and its parameters in an external file

save(outputFileName, 'map', 'mapLabel', 'elapsedTime', 'iEpoch', 'networkError', 'networkMissRate', 'validationError', 'validationMissRate', 'mapSize', 'L0', 'tauL', 'N0', 'tauN');