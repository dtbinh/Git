function hdr_som_lvq(Lratio, tauLratio, maxEpoch, varargin)

%
% FUNCTION DESCRIPTION
%

trainingDataSet = 'pendigits.tra';
validationDataSet = 'pendigits.val';

% Generate the complete data set cell array
completeDataSet = [parseDataSet(trainingDataSet) parseDataSet(validationDataSet)];

% Generate the agregated learningParameters cell array
learningParameters = cell(1,2);
learningParameters{1} = Lratio;
learningParameters{2} = tauLratio;

if(nargin == 3)
    % Find all files
    allFiles = dir;
    
    % Count the number of files and subtract 2 (because of '.' and '..')
    [nFile ~] = size(allFiles);
    nMatFile = nFile - 2;
    
    for iFile = 1:nMatFile
        hdr_som_train_lvq(allFiles(iFile+2).name, completeDataSet, learningParameters, maxEpoch)
    end
     
else
    % Run hdr_som_train_lvq
    hdr_som_train_lvq(varargin{1}, completeDataSet, learningParameters, maxEpoch)
end
    