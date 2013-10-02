function splitDataSet = divideDataSet(dataSet)

% DIVIDEDATASET Split the examples of a data set by output class
%    S = divideDataSet(dataSet) is a cell array containing nClass matrices 
%    where nClass is the number of different classes in the data set. Each 
%    matrix S{i} is formed by copying all the examples from the data set in 
%    which the output class equals to i+1. The dataSet must be provided in
%    a single matrix (not in the cell-array mode)
%
%    OBS: The output classes of the data set must be numerical values
%    ranging from 0 to nClass-1.
%
%    Hard-coded parameters:
%        nClass: The number of different classes in the data set
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: RESAMPLEDATASET

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% [hard-coded parameter] The number of different classes in the data set
nClass = 10;

% Measure the amount of examples in the data set
[nExample nData] = size(dataSet);

% Initialize the cell array and an array of indexes
splitDataSet = cell(1, nClass);
classCounter = ones(1, nClass);

for iExample = 1:nExample
    
    % Identify the class of the current example
    exampleClass = dataSet(iExample, nData) + 1;
    
    % Copy the current example to the correct matrix
    splitDataSet{exampleClass}(classCounter(exampleClass), :) = dataSet(iExample, :);
    
    % Increse the corresponding index
    classCounter(exampleClass) = classCounter(exampleClass) + 1;
end
    