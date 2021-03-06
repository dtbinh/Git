function neuronOut = neuronActivationFunction(neuronSum, functionType)

% NEURONACTIVATIONFUNCTION
%    neuronOut = neuronActivationFunction(neuronSum, functionType)
%    calculates the output of a given neuron, resulting from the neuron's
%    activation function applied to the neuronSum. The activation function
%    applied is selected from a set of pre-defined functions. The argument
%    functionType selects which function should be used.
%
%    Options for 'functionType'
%    --------------------------
%           1  --  Linear Function
%           2  --  Logistic Function
%           3  --  Hyperbolic Tangent (scaled to [0,1])
%           4  --  Hyperbolic Tangent ([-1,1])
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: HDR_MLP_TRAIN, NEURONDERIVATIVEFUNCTION

% Author: Andr� Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 22-September-2013

switch(functionType)
        
    % Linear Function
    case 1
        neuronOut = neuronSum;
    
    % Logistic Function
    case 2
        neuronOut = (1.0 ./ (1+exp(-neuronSum)));
        
    % Hyerbolic Tangent (scaled to [0,1])
    case 3
        neuronOut = 0.5 * (1 + tanh(neuronSum));
        
    % Hyerbolic Tangent ([-1,1])
    otherwise
        neuronOut = tanh(neuronSum);        
end