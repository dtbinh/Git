function hdr_mlp(varargin)

% HDR_MLP  Handwritten Digit Recognition Multilayer Perceptron (param_func)
%    Starts training a Multilayer Perceptron for solving the problem of
%    handwritten digit recognition, based on the data set "Pen-Based 
%    Recognition of Handwritten Digits" provided by UC Irvine, by calling 
%    the function hdr_mlp_train with the proper parameters.
%
%    HDR_MLP() starts training the Multilayer Perceptron using the default
%    parameters (printed on screen before running hdr_mlp_train)
%
%    HDR_MLP(filename) starts training the Multilayer Perceptron using the
%    parameters listed in an external text file. If the text file contains
%    more than one set of parameters, the function hdr_mlp_train is called
%    more than one time.
%
%
%  Other m-files required: hdr_mlp_train.m, loadDataSet.m
%  Subfunctions: generateCompleteDataSet
%  MAT-files required: none
%
% See also: HDR_MLP_TRAIN, HDR_MLP_TEST, LOADDATASET 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 23-September-2013

%% Default Parameters

% See help hdr_mlp_train for more information
d_trainingFile = 'pendigits.tra';
d_validationFile = 'pendigits.val';
d_nHiddenNeuron = [16];
d_functionType = [2 2];
d_learningRate = 0.01;
d_onlineMode = 1;
d_maxValidationMissRate = 0.0;
d_maxEpoch = 10000;
d_outputFolder = 'test';

%% Decodes VARARGIN

switch(nargin)
    
    % nargin == 0: run hdr_mlp_train with the default parameters
    case 0
        
        % Generate the complete data set cell array
        completeDataSet = generateCompleteDataSet(d_trainingFile, d_validationFile);
        
        % Groups the two stopping conditions into one cell array
        stoppingCondition = cell(1,2);
        stoppingCondition{1} = d_maxValidationMissRate;
        stoppingCondition{2} = d_maxEpoch;
        
        % Run hdr_mlp_train
        hdr_mlp_train(completeDataSet, d_nHiddenNeuron, d_functionType, d_learningRate, d_onlineMode, stoppingCondition, d_outputFolder);
        
    % nargin == 1: run hdr_mlp_train loading the parameters from an external file    
    case 1
        
        % Open the external file
        inputFile = fopen(varargin{1});
        
        % Load the parameters in a bidimensional cell array
        parameters = textscan(inputFile,'%s %s %s %s %f %d %f %d %s', 'delimiter', ',');
        
        % Close the external file
        fclose(inputFile);
        
        % For each row of the external file, run the hdr_mlp_train with the
        % appropriate parameters
        [nTestCase ~] = size(parameters{1});
        for iTestCase = 1:nTestCase
            
            % Generate the complete data set cell array
            completeDataSet = generateCompleteDataSet(parameters{1}{iTestCase}, parameters{2}{iTestCase});
            
            % nHiddenNeuron and functionType are read as strings because
            % they are 1-D arrays in the form "[x1 x2 ... xn]"
            nHiddenNeuron = str2num(parameters{3}{iTestCase});
            functionType = str2num(parameters{4}{iTestCase});
            
            learningRate = parameters{5}(iTestCase);
            onlineMode = parameters{6}(iTestCase);
            
            % Groups the two stopping conditions into one cell array
            stoppingCondition = cell(1,2);
            stoppingCondition{1} = parameters{7}(iTestCase);
            stoppingCondition{2} = parameters{8}(iTestCase);
            
            outputFolder = parameters{9}{iTestCase};
            
            % Run hdr_mlp_train
            hdr_mlp_train(completeDataSet, nHiddenNeuron, functionType, learningRate, onlineMode, stoppingCondition, outputFolder);
        end
        
    % nargin > 1: Invalid option- display error message for user
    otherwise
        fprintf('ERROR: Incorrect inputs format - See "help hdr_mlp" for more information');
end

function completeDataSet = generateCompleteDataSet(trainingFile, validationFile)
% [Subfunction] Generate a complete data set cell array structure
%    Simply use the function loadDataSet to load load the data sets
%    contained in the trainingFile and the validationFile. After that, put
%    the four obtained matrices in a single cell array.

trainingDataSet = loadDataSet(sprintf('datasets/%s',   trainingFile));
validationDataSet = loadDataSet(sprintf('datasets/%s', validationFile));
completeDataSet = cell(1,4);
completeDataSet{1} = trainingDataSet{1};
completeDataSet{2} = trainingDataSet{2};
completeDataSet{3} = validationDataSet{1};
completeDataSet{4} = validationDataSet{2};
