function resultCell = hdr_som_test(mapFile, dataSetFile, controlVariable)

%
% FUNCTION DESCRIPTION
%

%% Import data from the input files

% Load the self-organized map from mapFile. 
mapStruct = load(mapFile);

% Load the data set that will be used to test the trained neural network.
dataSet = parseDataSet(dataSetFile);

%% Test the self-organized map with the given data set

[error missRate] = testMap(mapStruct.map, mapStruct.mapLabel, dataSet{1}, dataSet{2});

%% Produce the test result cell array

% Initialize the result cell array
resultCell = cell(1,3);

% Select the control variable based on the provided parameter
if(strcmp(controlVariable, 'tauN'))
    resultCell{1} = mapStruct.tauN;
elseif(strcmp(controlVariable, 'tauL'))
    resultCell{1} = mapStruct.tauL;
elseif(strcmp(controlVariable, 'L0'))
    resultCell{1} = mapStruct.L0;
elseif(strcmp(controlVariable, 'mapSize'))
    resultCell{1} = mapStruct.mapSize;
end

% Copy the error and the miss rate into the result cell array
resultCell{2} = error;
resultCell{3} = missRate;