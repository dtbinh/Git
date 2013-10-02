function resultCell = hdr_mlp_test_all(dataSetFile, selectedControlVariable)

% HDR_MLP_TEST_ALL Test multiple MLP networks, trained with hdr_mlp_train
%    resultCell = HDR_MLP_TEST_ALL(dataSetFile, controlVariable) locate all
%    the available mat files in the current directory and run the function
%    hdr_mlp_test for each one of them. After that, all the results are
%    separated in three arrays, containing the different values of the
%    network error, the misclassification rate and a control variable. 
%    These three arrays are sorted in respect to the control variable to 
%    allow plotting. The resultCell is a cell array containing the three 
%    sorted arrays.
%
%    resultCell{1}: 1-D array of the control variable (sorted)
%    resultCell{2}: 1-D array of the network error
%    resultCell{3}: 1-D array of the network misclassification rate
%
%
%  Other m-files required: hdr_mlp_test.m, loadDataSet.m
%  Subfunctions: none
%  MAT-files required: trained networks (in the current directory)
%
%  See also: HDR_MLP_TRAIN, HDR_MLP_TEST, HDR_MLP_TEST_ALL_2D,
%  PLOTTESTRESULTS

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 30-September-2013

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
    
    % Run the function hdr_mlp_test for each trained network
    results{iFile} = hdr_mlp_test(matFiles{iFile}, dataSetFile, selectedControlVariable);
end

%% Split the obtained results into arrays for the control variable and the errors

% Initialize arrays for storing the control variables and the errors
controlVariable = zeros(1,nMatFile);
networkError = zeros(1,nMatFile);
networkMissRate = zeros(1,nMatFile);

% Separate the result of the tests into the initialized arrays
for iFile = 1:nMatFile
    controlVariable(iFile) = results{iFile}{1};
    networkError(iFile) = results{iFile}{2};
    networkMissRate(iFile) = results{iFile}{3};
end

%% Sort the obtained arrays for plotting

controlVariableSorted = zeros(1,nMatFile);
networkErrorSorted = zeros(1,nMatFile);
networkMissRateSorted = zeros(1,nMatFile);
for iFile = 1:nMatFile
    [~, index] = min(controlVariable);
    controlVariableSorted(iFile) = controlVariable(index);
    networkErrorSorted(iFile) = networkError(index);
    networkMissRateSorted(iFile) = networkMissRate(index);
    controlVariable(index) = max(controlVariable) + 1;
end

%% Produce the test result cell array

resultCell = cell(1,3);
resultCell{1} = controlVariableSorted;
resultCell{2} = networkErrorSorted;
resultCell{3} = networkMissRateSorted;