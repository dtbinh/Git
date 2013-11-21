function dataSet = parseDataSet(dataSetFile)

%
% FUNCTION DESCRIPTION
%

% Read the entire data set from file
dataSetMatrix = load(sprintf('datasets/%s',   dataSetFile));

% Measure the amount of data per example in the data set
nData = size(dataSetMatrix, 2);

% Split the data set matrix into inputs and outputs
inputMatrix = dataSetMatrix(:, 1:nData-1);
outputMatrix = dataSetMatrix(:, nData);

% Normalize the input matrix to the range [-1 1]
inputMatrix = inputMatrix - min(min(inputMatrix));
inputMatrix = inputMatrix ./ (max(max(inputMatrix)) / 2);
inputMatrix = inputMatrix - 1;

% Group the input and output matrices in a cell array
dataSet = cell(1,2);
dataSet{1} = inputMatrix;
dataSet{2} = outputMatrix;