function resultCell = hdr_som_test_all_2D(dataSetFile, selectedControlVariable)

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
    
    % Run the function hdr_som_test for each trained network
    results{iFile} = hdr_som_test(matFiles{iFile}, dataSetFile, selectedControlVariable);
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
    controlVariableCost(iFile) = 1000*controlVariable1(iFile) + controlVariable2(iFile);
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
tx = linspace(min(x), max(x), 100);
ty = linspace(min(y), max(y), 100);
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