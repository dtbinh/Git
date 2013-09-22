function neuronOut = neuronActivationFunction(neuronSum, functionType)

% NEURONACTIVATIONFUNCTION
%    neuronOut = NEURONACTIVATIONFUNCTION(neuronSum, functionType)
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
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: HDR_MLP_TRAIN 

% Author: André Augusto Geraldes
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
    otherwise
        neuronOut = 0.5 * (1 + tanh(neuronSum));
end