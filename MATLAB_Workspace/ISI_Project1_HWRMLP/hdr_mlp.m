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
%    default parameters (printed on screen before running the hdr_mlp_train
%    function)
%
%    HDR_MLP('file', filename) starts training the Multilayer Perceptron
%    using the parameters listed in an external text file. If the text file
%    contains more than one set of parameters, the function hdr_mlp_train
%    is called more than one time.
%
%  Other m-files required: hdr_mlp_train.m
%  Subfunctions: acquireParametersFromUser, loadDataSet
%  MAT-files required: none
%
% See also: HDR_MLP_TRAIN 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 11-September-2013

clearvars -except varargin;
close all;

%% Default Parameters

d_dataSetFile = 'pendigits.tra';
d_nHiddenLayer = 1;
d_nHiddenNeuron = [12];
d_functionType = [2 2];
d_learningRate = 0.1;
d_maxError = 0;

%% Decodes VARARGIN
inputError = 0;

switch(nargin)
    case 0
        [inputError parameters] = acquireParametersFromUser();
        if(~inputError)
            trainingDataSet = loadDataSet(parameters{1});    
            hdr_mlp_train(trainingDataSet, parameters{2}, parameters{3}, parameters{4}, parameters{5}, parameters{6})
        end
    case 1
        if(varargin{1} ~= 'd')
            inputError = 1;   
        else
            trainingDataSet = loadDataSet(d_dataSetFile);    
            hdr_mlp_train(trainingDataSet, d_nHiddenLayer, d_nHiddenNeuron, d_functionType, d_learningRate, d_maxError)
        end
    case 2
        if(varargin{1} ~= 'f')
            inputError = 1;
        else
            % OPEN THE TEXT FILE varargin{2} AND START LAUNCHING
            % hdr_mlp_train with the parameters contained in it
        end        
    otherwise
        inputError = 1;
end

if(inputError)
    disp('ERROR: Incorrect inputs format - See "help hdr_mlp" for more information');
end


function [inputError parameters] = acquireParametersFromUser()
% FUNCTION DESCRIPTION

inputError = 0;
parameters = cell(1,6);


% Ask the inputs to the user one after the other
% modify the default parameters with the acquired ones
% for each parameter, verify its validity



function trainingDataSet = loadDataSet(d_dataSetFile)
% FUNCTION DESCRIPTION
% OBS: INSERT COMMENDS BETWEEN THE FOLLOWING LINES OF CODE

dataSetMatrix = load(d_dataSetFile);
inputMatrix = dataSetMatrix(:,1:16);
[nExample ~] = size(dataSetMatrix);
outputMatrix = 0.1 + zeros(nExample,10);
for iExample = 1:nExample
    outputMatrix[iExample,dataSetMatrix(iExample,17)] = 0.9;
end
trainingDataSet = cell(1,2);
trainingDataSet{1} = inputMatrix;
trainingDataSet{2} = outputMatrix;





