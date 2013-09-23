function hdr_mlp(varargin)

% HDR_MLP  Handwritten Digit Recognition Multilayer Perceptron (param_func)
%    Starts training a Multilayer Perceptron for solving the problem of
%    handwritten digit recognition, based on the datasets provided by 
%    E. Alpaydin and Fevzi. Alimoglu, by calling the function hdr_mlp_train
%    with the proper parameters.
%
%    HDR_MLP() asks the user for the parameters that should be used for
%    training the Multilayer Perceptron. Parameters are asked one after the
%    other by command line messages. After all parameters are set the
%    function hdr_mlp_train is called.
%
%    HDR_MLP('d') starts training the Multilayer Perceptron using the
%    default parameters (printed on screen before running hdr_mlp_train)
%
%    HDR_MLP('f', filename) starts training the Multilayer Perceptron
%    using the parameters listed in an external text file. If the text file
%    contains more than one set of parameters, the function hdr_mlp_train
%    is called more than one time.
%
%  Other m-files required: hdr_mlp_train.m, loadDataSet.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: HDR_MLP_TRAIN, HDR_MLP_TEST, LOADDATASET 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 23-September-2013

clearvars -except varargin;
close all;

%% Default Parameters

d_dataSetFile = 'pendigits.tra';
d_nHiddenNeuron = [16];
d_functionType = [2 2];
d_learningRate = 0.01;
d_onlineMode = 1;
d_maxEpochErrr = 0.0;
d_maxEpoch = 10000;
d_outputFolder = 'test';

%% Decodes VARARGIN

inputError = 0;
switch(nargin)
    
    % Case 0 - ask parameters from user, one after the other
    case 0
        fprintf('DEBUG - ASKING PARAMETERS FROM USER NOT IMPLEMENTED YET\n');
        inputError = 1;
    
    % Case 1 - run hdr_mlp_train with the default parameters
    case 1
        if(varargin{1} ~= 'd')
            inputError = 1;   
        else
            trainingDataSet = loadDataSet(d_dataSetFile);
            stoppingCondition = cell(1,2);
            stoppingCondition{1} = d_maxEpochErrr;
            stoppingCondition{2} = d_maxEpoch;
            hdr_mlp_train(trainingDataSet, d_nHiddenNeuron, d_functionType, d_learningRate, d_onlineMode, stoppingCondition, d_outputFolder);
        end
        
    % Case 2 - run hdr_mlp loading the parameters from an external file    
    case 2
        if(varargin{1} ~= 'f')
            inputError = 1;
        else
            inputFile = fopen(varargin{2});
            parameters = textscan(inputFile,'%s %s %s %f %d %f %d %s', 'delimiter', ',');
            fclose(inputFile);
            [~, nTestCase] = size(parameters);
            for iTestCase = 1:nTestCase
                trainingDataSet = loadDataSet(parameters{1}{iTestCase});
                nHiddenNeuron = str2num(parameters{2}{iTestCase});
                functionType = str2num(parameters{3}{iTestCase});
                learningRate = parameters{4}(iTestCase);
                onlineMode = parameters{5}(iTestCase);
                stoppingCondition = cell(1,2);
                stoppingCondition{1} = parameters{6}(iTestCase);
                stoppingCondition{2} = parameters{7}(iTestCase);
                outputFolder = parameters{8}{iTestCase};
                hdr_mlp_train(trainingDataSet, nHiddenNeuron, functionType, learningRate, onlineMode, stoppingCondition, outputFolder);
            end
        end        
    otherwise
        inputError = 1;
end

if(inputError)
    disp('ERROR: Incorrect inputs format - See "help hdr_mlp" for more information');
end

