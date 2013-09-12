function hdr_mlp(varargin)

% HDR_MLP  Handwritten Digit Recognition Multilayer Perceptron (param_func)
%    Starts training a Multilayer Perceptron for solving the problem of
%    handwritten digit recognition, based on the datasets provided by 
%    E. Alpaydin and Fevzi. Alimoglu, by calling the function hdr_mlp_train
%    with the proper parameters
%
%    HDR_MLP() asks the user for the parameters that should be used for
%    training the Multilayer Perceptron. Parameters are asked one after the
%    other by command line messages. After all parameters are set the
%    function HDR_MLP_train is called
%
%    HDR_MLP('default') starts training the Multilayer Perceptron using the
%    defautl parameters (printed on screen before running the hdr_mlp_train
%    function)
%
% Other m-files required: hdr_mlp_train.m
%
% See also: HDR_MLP_TRAIN, HDR_MLP_EVAL

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 11-September-2013



% Decodes the number of received inputs
%  - No input: start training the neural network with the pre-defined
%  parameters
switch(nargin)
    case 0
        disp('zero');
    case 1
        disp('one');
    otherwise
        disp('two');
end


