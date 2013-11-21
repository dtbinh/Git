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

% Copy the error and the miss rate into the result cell array
resultCell{2} = error;
resultCell{3} = missRate;

% Select the control variable based on the provided parameter
if(strcmp(controlVariable, 'L0'))
    resultCell{1} = mapStruct.L0;
elseif(strcmp(controlVariable, 'L0Log'))
    resultCell{1} = log(mapStruct.L0);
elseif(strcmp(controlVariable, 'Lf'))
    resultCell{1} = mapStruct.Lf;
elseif(strcmp(controlVariable, 'LfLog'))
    resultCell{1} = log(mapStruct.Lf);
elseif(strcmp(controlVariable, 'L0Lf'))
    resultCell{1} = mapStruct.L0 + mapStruct.Lf;    
elseif(strcmp(controlVariable, 'sigma'))
    resultCell{1} = mapStruct.learningParameters{3} + mapStruct.learningParameters{4} * 2;
elseif(strcmp(controlVariable, 'mapSize'))
    resultCell{1} = mapStruct.mapSize;
    resultCell{2} = mapStruct.elapsedTime;
elseif(strcmp(controlVariable, '2D_L0Lf'))    
    resultCell{1} = cell(1,2);
    resultCell{1}{1} = mapStruct.L0;
    resultCell{1}{2} = mapStruct.Lf;
elseif(strcmp(controlVariable, '2D_L0LfLog'))    
    resultCell{1} = cell(1,2);
    resultCell{1}{1} = log(mapStruct.L0);
    resultCell{1}{2} = log(mapStruct.Lf);    
elseif(strcmp(controlVariable, '2D_sigma'))    
    resultCell{1} = cell(1,2);
    resultCell{1}{1} = mapStruct.learningParameters{3};
    resultCell{1}{2} = mapStruct.learningParameters{4};        
end

