function hdr_som(varargin)

%
% FUNCTION DESCRIPTION
%

%% Default Parameters

% See help hdr_mlp_train for more information
d_trainingFile = 'pendigits.tra';
d_validationFile = 'pendigits.val';
d_mapSize = 11;
d_circularMap = 0;
d_L0 = 0.1;
d_Lf = 0.001;
d_S0 = 1.0;
d_Sf = 0.01;
d_maxEpoch = 1000;
d_outputFolder = 'test';

%% Decodes VARARGIN

switch(nargin)
    
    % nargin == 0: run hdr_mlp_train with the default parameters
    case 0
        
        % Generate the complete data set cell array
        completeDataSet = [parseDataSet(d_trainingFile) parseDataSet(d_validationFile)];
        
        % Generate the agregated learningParameters cell array
        learningParameters = cell(1,4);
        learningParameters{1} = d_L0;        
        learningParameters{2} = d_Lf;
        learningParameters{3} = d_S0;
        learningParameters{4} = d_Sf;
        
        % Run hdr_som_train
        hdr_som_train(completeDataSet, d_mapSize, d_circularMap, learningParameters, d_maxEpoch, d_outputFolder);
        
    % nargin == 1: run hdr_mlp_train loading the parameters from an external file    
    case 1
        
        % Open the external file
        inputFile = fopen(varargin{1});
        
        % Load the parameters in a bidimensional cell array
        parameters = textscan(inputFile,'%s %s %d %d %d %f %f %f %f %s', 'delimiter', ',');
        
        % Close the external file
        fclose(inputFile);
        
        % For each row of the external file, run the hdr_mlp_train with the
        % appropriate parameters
        nTestCase = size(parameters{1}, 1);
        for iTestCase = 1:nTestCase
            
            % Generate the complete data set cell array
            completeDataSet = [parseDataSet(parameters{1}{iTestCase}) parseDataSet(parameters{2}{iTestCase})];
            
            mapSize = parameters{3}(iTestCase);
            maxEpoch = parameters{4}(iTestCase);
            circularMap = parameters{5}(iTestCase);
            
            % Generate the agregated learningParameters cell array
            learningParameters = cell(1,4);
            learningParameters{1} = parameters{6}(iTestCase);
            learningParameters{2} = parameters{7}(iTestCase);
            learningParameters{3} = parameters{8}(iTestCase);
            learningParameters{4} = parameters{9}(iTestCase);
            
            outputFolder = parameters{10}{iTestCase};
            
            % Run hdr_som_train
            hdr_som_train(completeDataSet, double(mapSize), circularMap, learningParameters, double(maxEpoch), outputFolder);
        end
        
    % nargin > 1: Invalid option- display error message for user
    otherwise
        fprintf('ERROR: Incorrect inputs format - See "help hdr_som" for more information');
end