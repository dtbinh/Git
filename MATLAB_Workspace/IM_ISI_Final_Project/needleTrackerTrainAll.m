function needleTrackerTrainAll(datFile)

%
% FUNCTION DESCRIPTION
%

% Open the external file
inputFile = fopen(datFile);

% Load the parameters in a bidimensional cell array
parameters = textscan(inputFile,'%s %s %s %s %s %f %d %s', 'delimiter', ',');

% Close the external file
fclose(inputFile);

% For each row of the external file, run the hdr_mlp_train with the
% appropriate parameters
[nTestCase ~] = size(parameters{1});
for iTestCase = 1:nTestCase
    
    trainingFile = parameters{1}{iTestCase};
    validationFile = parameters{2}{iTestCase};
    trainingFunction = parameters{3}{iTestCase};
    
    hiddenLayers = str2num(parameters{4}{iTestCase});
    
    layerFunctions = parameters{5}{iTestCase};
    stringSeparators = find(layerFunctions == '-');
    nLayer = size(stringSeparators, 2) + 1;
    functionType = cell(1,nLayer);
    functionType{1} = layerFunctions(1:stringSeparators(1)-1);
    for iLayer = 2:nLayer-1
        functionType{iLayer} = layerFunctions(stringSeparators(iLayer-1)+1:stringSeparators(iLayer)-1);
    end
    functionType{nLayer} = layerFunctions(stringSeparators(nLayer-1)+1:length(layerFunctions));
    
    learningRate = parameters{6}(iTestCase);
    
    maxEpoch = parameters{7}(iTestCase);

    outputFolder = parameters{8}{iTestCase};
    
    needleTrackerTrain(trainingFile, validationFile, trainingFunction, hiddenLayers, functionType, learningRate, maxEpoch, outputFolder);
end

