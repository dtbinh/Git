function dataSet = loadDataSet(dataSetFileName)

% LOADDATASET
%    dataset = LOADDATASET(dataSetFileName) reads the external file and
%    parses it's data into a cell array containing two matrices: the
%    'inputMatrix' and the 'ouputMatrix'. Each row of the outputMatrix
%    contains the desired output of the neural network, in respect to the
%    set of inputs in the corresponding row of the 'inputMatrix'.
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: HDR_MLP, HDR_MLP_TRAIN 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 22-September-2013


% Parameter - the set of available classes for the output values of the
% dataset. It has been hard-coded for convenience as this parameter doesn't
% change often.
class = [0 1 2 3 4 5 6 7 8 9];

% Read the entire data set from file
dataSetMatrix = load(dataSetFileName);

% Measure the amount of examples in the data set
[nExample nData] = size(dataSetMatrix);

% Determine the number of inputs and ouputs per example of the data set
nInput = nData-1;
[~, nOutput] = size(class);

% Extract the input values from the data set into a separated matrix
inputMatrix = dataSetMatrix(:, 1:nInput);

% Create matrix for storing the ouput values
outputMatrix = 0.1 + zeros(nExample,nOutput);

for iExample = 1:nExample
    
    % Fill the output matrix by setting one output to '0.9' per example. 
    % The set output is the one corresponding to the example's class
    classIndex = find(dataSetMatrix(iExample,nData) == class);
    outputMatrix(iExample, classIndex) = 0.9;
end

% Normalize the input matrix to the range [-1 1]
inputMatrix = inputMatrix - min(min(inputMatrix));
inputMatrix = inputMatrix ./ (max(max(inputMatrix)) / 2);
inputMatrix = inputMatrix - 0.1;

% Group the input and output matrices in a cell array
dataSet = cell(1,2);
dataSet{1} = inputMatrix;
dataSet{2} = outputMatrix;
