function resultCell = hdr_mlp_test_all_2D(dataSetFile, selectedControlVariable)

% HDR_MLP_TEST_ALL_2D  Test trained MLP networks using 2 control variables
%    resultCell = hdr_mlp_test_all_2D(dataSetFile, controlVariable) locate all
%    the available mat files in the current directory and run the function
%    hdr_mlp_test for each one of them. The controlVariable must be a
%    string specifying one set of two control variables (See help hdr_mlp
%    for more information). After that, all the results are separated in 
%    four arrays, containing the different values of the network error, the
%    misclassification rate and the two control variables. The network
%    error and the misclassification rate are then converted to matrices,
%    using the 3D interpolation function griddata. 
%    The resultCell is a cell array containing the interpolated 3D surfaces
%    for the network error and the misclassification rate alongside the
%    interpolated arrays for the two control variables.
%
%    resultCell{1}: 1-D array of representing the first control variable
%    resultCell{2}: 1-D array of representing the second control variable
%    resultCell{3}: 3D interpolated surface representing the network error
%    resultCell{4}: 3D interpolated surface representing the network
%    misclassification rate
%
%    Note: using mesh(resultCell{1}, resultCell{2}, resultCell{3 or 4})
%    gives a good understanding of the behavior of the network error and
%    network misclassification rate in respect to the control variables,
%    however the exact values can not be trusted as they are the result of
%    a 3D interpolation function and not the real error and
%    misclassification rate produced by the network.
%
%  Other m-files required: hdr_mlp_test.m
%  Subfunctions: none
%  MAT-files required: trained networks (in the current directory)
%
%  See also: HDR_MLP_TRAIN, HDR_MLP_TEST, HDR_MLP_TEST_ALL_2D,
%  PLOTTESTRESULTS, GRIDDATA

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

%% Split the obtained results into arrays for the control variables and the errors

% Initialize arrays for storing the control variables and the errors
controlVariable1 = zeros(1,nMatFile);
controlVariable2 = zeros(1,nMatFile);
networkError = zeros(1,nMatFile);
networkMissRate = zeros(1,nMatFile);

% The cost function is used to sort the two control variables at the same
% time
controlVariableCost = zeros(1,nMatFile);

% Separate the result of the tests into the initialized arrays
for iFile = 1:nMatFile
    controlVariable1(iFile) = results{iFile}{1}{1};
    controlVariable2(iFile) = results{iFile}{1}{2};
    controlVariableCost(iFile) = 10*controlVariable1(iFile) + controlVariable2(iFile);
    networkError(iFile) = results{iFile}{2};
    networkMissRate(iFile) = results{iFile}{3};
end

%% Sort the obtained arrays for plotting

% Initialize arrays for storing the sorted data
% The arrays have been named with short variables to simplify the final
% data processing stage
x = zeros(1,nMatFile);
y = zeros(1,nMatFile);
error = zeros(1,nMatFile);
missRate = zeros(1,nMatFile);

for iFile = 1:nMatFile
    
    % Sort the data using the cost function
    [~, index] = min(controlVariableCost);
    x(iFile) = controlVariable1(index);
    y(iFile) = controlVariable2(index);
    error(iFile) = networkError(index);
    missRate(iFile) = networkMissRate(index);
    controlVariableCost(index) = max(controlVariableCost) + 1;
end

%% Convert the error and the miss rate into matrices

% Generate reference arrays xi and yi that represent the entire range
% covered by the variables x and y
tx = min(x):max(x);
ty = min(y):max(y);
[xi yi] = meshgrid(tx, ty);

% Generate 3D interpolations of the data represented by the triples
% (x,y,error) and (x,y,missRate)
errorMesh = griddata(x, y, error, xi, yi);
missRateMesh = griddata(x, y, missRate, xi, yi);

%% Display the interpolated 3D surfaces using the mesh function

figure;
mesh(xi, yi, errorMesh);
figure;
mesh(xi, yi, missRateMesh);

%% Produce the test result cell array

resultCell = cell(1,4);
resultCell{1} = xi;
resultCell{2} = yi;
resultCell{3} = errorMesh;
resultCell{4} = missRateMesh;