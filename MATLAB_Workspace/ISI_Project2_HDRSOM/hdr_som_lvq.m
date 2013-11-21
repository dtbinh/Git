function hdr_som_lvq(L0, Lf, maxEpoch, varargin)

%
% FUNCTION DESCRIPTION
%

% Generate the agregated learningParameters cell array
learningParameters = cell(1,2);
learningParameters{1} = L0;
learningParameters{2} = Lf;

if(nargin == 3)
    % Find all files
    allFiles = dir;
    
    % Count the number of files and subtract 2 (because of '.' and '..')
    [nFile ~] = size(allFiles);
    nMatFile = nFile - 2;
    
    for iFile = 1:nMatFile
        hdr_som_train_lvq(allFiles(iFile+2).name, learningParameters, maxEpoch)
    end
     
else
    % Run hdr_som_train_lvq
    hdr_som_train_lvq(varargin{1}, learningParameters, maxEpoch)
end
    