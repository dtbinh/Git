function [error missRate] = testMap(map, mapLabel, input, output)

%
% FUNCTION DESCRIPTION
%

% Measure the size of the map and the inputs matrix
mapSize = size(map,1);
[nExample nInput] = size(input);

% inputVector is 1x1xnInput vector for parsing each example of the data set
inputVector = zeros(1, 1, nInput);

% Initialize the error and missRate counters with 0
error = 0;
missRate = 0;

% For each example in the data set:
for iExample = 1:nExample
    
    % Retrieve the current example and parse it into the inputVector
    inputVector(1,1,:) = input(iExample,:);
    
    % Compute the euclidian distance between the each neuron an the example
    distance = sqrt(sum((map-repmat(inputVector,mapSize)).^2, 3));
    
    % Find the closest neuron to the current example
    [r c] = find(distance == min(min(distance)));
    
    % Set the error as the distance between the current example and the
    % closest neuron
    error = error + min(min(distance));
   
    % Check if the label of the closest neuron matches the label of the
    % example. If not, increase the missRate
    if(mapLabel(r(1), c(1)) ~= output(iExample))
        missRate = missRate + 1.0;
    end
    
end

% Normalize the error and missRate counters in respect to the total number
% of examples
error = error / nExample;
missRate = missRate / nExample;