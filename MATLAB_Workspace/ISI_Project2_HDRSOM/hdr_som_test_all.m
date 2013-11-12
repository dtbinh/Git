function resultCell = hdr_som_test_all(dataSetFile, selectedControlVariable)

%
% FUNCTION DESCRIPTION
%

%% Find all mat files in the current directory

% Find all files
allFiles = dir;

% Count the number of files and subtract 2 (because of '.' and '..')
[nFile ~] = size(allFiles);
nMatFile = nFile - 2;

% Read the name of all mat files into a cell array
matFiles = cell(nMatFile,1);
for iFile = 1:nMatFile
    matFiles{iFile} = allFiles(iFile+2).name;
end

%% For each mat file, test the trained network using the same data set

results = cell(1, nMatFile);
for iFile = 1:nMatFile  
    results{iFile} = hdr_som_test(matFiles{iFile}, dataSetFile, selectedControlVariable);
    if(strcmp(selectedControlVariable, 'index'))
        results{iFile}{1} = iFile;
    end
end

%% Split the obtained results into arrays for the control variable and the errors

% Initialize arrays for storing the control variables and the errors
controlVariable = zeros(1,nMatFile);
error = zeros(1,nMatFile);
missRate = zeros(1,nMatFile);

% Separate the result of the tests into the initialized arrays
for iFile = 1:nMatFile
    controlVariable(iFile) = results{iFile}{1};
    error(iFile) = results{iFile}{2};
    missRate(iFile) = results{iFile}{3};
end

%% Sort the obtained arrays for plotting

controlVariableSorted = zeros(1,nMatFile);
errorSorted = zeros(1,nMatFile);
missRateSorted = zeros(1,nMatFile);
for iFile = 1:nMatFile
    [~, index] = min(controlVariable);
    controlVariableSorted(iFile) = controlVariable(index);
    errorSorted(iFile) = error(index);
    missRateSorted(iFile) = missRate(index);
    controlVariable(index) = max(controlVariable) + 1;
end

%% Produce the test result cell array

resultCell = cell(1,3);
resultCell{1} = controlVariableSorted;
resultCell{2} = errorSorted;
resultCell{3} = missRateSorted;