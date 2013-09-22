function outputArray = neuronDerivativeFunction(inputArray, functionType)

% NEURONDERIVATIVEFUNCTION
%    neuronOut = NEURONDERIVATIVEFUNCTION(neuronSum, functionType)
%    calculates the derivative of the neuron's activation function, 
%    resulting from applying the derivative function to the neuronSum. The 
%    derivative function applied is selected from a set of pre-defined 
%    functions (it matches the functions described in the 
%    neuronActivationFunction). The argument functionType selects which 
%    function should be used.
%
%    Options for 'functionType'
%    --------------------------
%           1  --  Linear Function
%           2  --  Logistic Function
%           3  --  Hyperbolic Tangent (scaled to [0,1])
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: NEURONACTIVATIONFUNCTION, HDR_MLP_TRAIN 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 22-September-2013


switch(functionType)
        
    % Linear
    case 1
        outputArray = ones(size(inputArray));
    
    % Logistic Function
    case 2
%         outputArray = 2.0 * (inputArray .* (1-inputArray));
        outputArray = (inputArray .* (1-inputArray));
        
    % Hyerbolic Tangent (scaled to [0,1])
    otherwise
        outputArray = 0.5 .* sech(inputArray) .* sech(inputArray);
end