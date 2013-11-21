function hdr_som_train(dataSet, mapSize, circularMap, learningParameters, maxEpoch, outputFolder)

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

% Lf is the final value of the learning rate (L(maxEpoch) = Lf)
Lf = learningParameters{2};

% tauL is the time constant associated to the decrease of L. 
tauL = maxEpoch/log(L0/Lf);

% sigma0 is the initial value of the variance of the 2D gaussian kernel
% used to describe a neighbourhood around the winning neuron. It is given
% as a fraction of mapSize/2
sigma0 = mapSize * learningParameters{3} / 2.0;

% sigmaf is the final value of the variance of the 2D gaussian kernel
% (sigma(maxEpoch) = sigmaf)
sigmaf = mapSize * learningParameters{4} / 2.0;

% tauSigma is the time constant associated to the decrease of sigma. 
tauSigma = maxEpoch/log(sigma0/sigmaf);          
            
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

%% Initialize the performance measurement variables

% trainingError stores the progression of the average euclidian distance
% between the map and the inputs. It is measured using the function testMap
% with the training data set, at the end of each epoch.
trainingError = zeros(1,maxEpoch);

% trainingMissRate stores the progression of the map misclassification
% rate, measured using the function testMap with the training data set, at
% the end of each epoch.
trainingMissRate = zeros(1,maxEpoch);

% validationError stores the progression of the average euclidian distance
% between the map and the inputs. It is measured using the function testMap
% with the validation data set, at the end of each epoch.
validationError = zeros(1,maxEpoch);

% validationmissRate stores the progression of the map misclassification
% rate, measured using the function testMap with the validation data set, at
% the end of each epoch.
validationMissRate = zeros(1,maxEpoch);

% learningRate stores the progression of L 
learningRate = zeros(1,maxEpoch);

% gaussianSigma stores the progression of sigma
gaussianSigma = zeros(1,maxEpoch);

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
fprintf('\t Training Length: %d epochs\n', maxEpoch);
fprintf('\t Learning Rate: L = %f * exp(-t / %f) [L(%d) = %f]\n', L0, tauL, maxEpoch, Lf);
fprintf('\t Gaussian Variance: Sigma = %f * exp(-t / %f) [Sigma(%d) = %f]\n', sigma0, tauSigma, maxEpoch, sigmaf);
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
    
    % Update the values of L and sigma
    t = double(iEpoch-1);
    L = L0 * exp(-t/tauL);
    sigma = sigma0 * exp(-t/tauSigma);
    
    % Update the gaussian kernel. The gaussian kernel should always be an
    % odd sized matriz, otherwise the peak of the Gaussian will always be
    % split between four slots.
    if(mod(mapSize,2) == 0)
        gaussianMatrix = fspecial('gaussian', mapSize+1, sigma);
    else
        gaussianMatrix = fspecial('gaussian', mapSize, sigma);
    end
    
    % Store the values of L and sigma for plotting
    learningRate(iEpoch) = L;
    gaussianSigma(iEpoch) = sigma;
    
    % For each example of the training data set:
    for iExample = 1:nExample
        
        % Compute the difference vectors between the input and each neuron
        % in the map
        differenceVector = repmat(reshape(input(iExample,:), [1 1 nInput]), mapSize) - map;
        
        % Compute the euclidian distance between the each neuron an the input
        distance = sqrt(sum((differenceVector).^2, 3));
        
        % Find the closest neuron to the input
        [r c] = find(distance == min(min(distance)));
        
        % Translate the the gaussian matrix to the coordinate of the wining
        % neuron
        diracMatrix = zeros(mapSize);
        diracMatrix(r(1),c(1)) = 1;
        
        if(circularMap)
            
            % If the map topology is toroidal, use circular convolution
            translatedGaussianMatrix = conv2(diracMatrix, repmat(gaussianMatrix,3), 'same');
        else
            
            % If the map topology is planar, use normal convolution and
            % normalize the obtained Gaussian
            translatedGaussianMatrix = conv2(diracMatrix, gaussianMatrix, 'same');
            translatedGaussianMatrix = translatedGaussianMatrix / sum(sum(translatedGaussianMatrix));
        end
        
        % Update the map
        map = map + L * repmat(translatedGaussianMatrix, [1 1 nInput]) .* differenceVector;
    end
    
    % At the end of the epoch, label the current map
    mapLabel = labelMap(map, input, output);
    
    % Measure the current map's performance in the training data set
    [error missRate] = testMap(map, mapLabel, input, output);
    trainingError(iEpoch) = error;
    trainingMissRate(iEpoch) = missRate;
    
    % Measure the current map's performance in the validation data set
    if(validationDataSet)
        [error missRate] = testMap(map, mapLabel, validationInput, validationOutput);
        validationError(iEpoch) = error;
        validationMissRate(iEpoch) = missRate;
    end
    
    % Update the trainingError and trainingMissRate graphs
    if(mod(iEpoch, updateRate) == 0)
        figure(errorFigure)
        subplot(2,3,[1 4]); 
        hold off; plot(trainingError(1:iEpoch), '-b');
        hold on;  plot(validationError(1:iEpoch), '-r');
        subplot(2,3,[2 5]); 
        hold off; plot(trainingMissRate(1:iEpoch), '-b');
        hold on;  plot(validationMissRate(1:iEpoch), '-r');
        subplot(2,3,3); 
        plot(learningRate(1:iEpoch));
        subplot(2,3,6); 
        plot(gaussianSigma(1:iEpoch));
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
fprintf('End of training! Total time = %f\n', elapsedTime);

%% Store the generated map and its parameters in an external file

save(outputFileName);