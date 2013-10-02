function resampleDataSetAndSave(inputDataSetFile, resampledFile1, resampledFile2, percentage)

% RESAMPLEDATASETANDSAVE Load data set from file and generate resampled data sets
%    resampleDataSetAndSave(iFile, oFile1, oFile2, p) loads a data set from
%    iFile and call the function resampleDataSet to generate the smaller
%    data sets ds1 and ds2. Save ds1 to the text file oFile1 and ds2 to
%    oFile2.
%
%  Other m-files required: resampleDataSet.m, divideDataSet.m,
%  unsortMatrix.m, saveDataSet.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: DIVIDEDATASET, RESAMPLEDATASET, SAVEDATASET, UNSORTMATRIX

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Load the data set from file (OBS: data set is loaded as matrix, not as
% cell array, then the function loadDataSet should not be used in this
% case)
inputDataSet = load(inputDataSetFile);

% Generate the resampled data sets
[resampledDataSet1 resampledDataSet2] = resampleDataSet(inputDataSet, percentage);

% Save the resampled data sets to text files
saveDataSet(resampledDataSet1, resampledFile1);
saveDataSet(resampledDataSet2, resampledFile2);
