function label = labelMap(map, input, output)

%
% FUNCTION DESCRIPTION
%

% Measure the size of the map and the inputs matrix
mapSize = size(map,1);
[nExample nInput] = size(input);

% neuron is an array used to parse each neuron of the map
neuron = zeros(1,nInput);

% Initialize the matrix of labels
label = zeros(mapSize, mapSize);

% For each neuron in the map:
for i = 1:mapSize 
    for j = 1:mapSize
        
        % parse the neuron into the 1xnInput array
        neuron(1,:) = map(i,j,:);
        
        % replicate the neuron to a nExample x nInput matrix and measure
        % the distance between the neuron to each example in the data set
        distance = sqrt(sum((repmat(neuron,nExample,1)-input).^2, 2));
        
        % find the closest example to the given neuron
        [r ~] = find(distance == min(min(distance)));
        
        % label the neuron using the class of the closes example
        label(i,j) = output(r(1));
        
    end
end