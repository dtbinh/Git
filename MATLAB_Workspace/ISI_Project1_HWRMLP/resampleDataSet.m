function [resampledDataSet1 resampledDataSet2] = resampleDataSet(dataSet, percentage);

% RESAMPLEDATASET Resample data set
%    [ds1 ds2] = resampleDataSet(dataSet, p) generate smaller data sets ds1
%    and ds2 by resampling examples from the original data set. The number
%    of examples in the resampled data sets are:
%
%        N(ds1) = p * N(dataSet)
%        N(ds2) = N(dataSet) - N(ds1)
%
%    Before starting to resample, the dataSet is split per classes using
%    the function divideDataSet. Then the split matrices are shuffled by
%    the function unsortMatrix. After that ds1 is formed by taking randomly
%    chosed examples from the split matrices so that the number of examples
%    per class has the same distribution as the original dataSet.
%
%
%  Other m-files required: divideDataSet.m, unsortMatrix.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: DIVIDEDATASET, RESAMPLEDATASETANDSAVE, UNSORTMATRIX

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Split the original data set separating the examples per class
splitDataSet = divideDataSet(dataSet);

% Get the number of classes and the amount of data per example
[~, nClass] = size(splitDataSet);
[~, nData] = size(splitDataSet{1});

% Prepare arrays for calculating the amount of examples in the resampled
% matrices
niClassResampled1 = zeros(1, nClass);
niClassResampled2 = zeros(1, nClass);

for iClass = 1:nClass
    
    % Calculate how many examples of the class iClass should go into resampledDataSet1
    [niClass ~] = size(splitDataSet{iClass});
    niClassResampled1(iClass) = round(niClass * percentage);
    niClassResampled2(iClass) = niClass - niClassResampled1(iClass);
    
end

% Initialize the matrices for storing the resampled data sets
resampledDataSet1 = zeros(sum(niClassResampled1), nData);
resampledDataSet2 = zeros(sum(niClassResampled2), nData);

iResampledExample1 = 1;
iResampledExample2 = 1;

for iClass = 1:nClass
    
    % Shuffle the split matrix
    iClassDataSet = unsortMatrix(splitDataSet{iClass}, 'r');
    [nExample ~] = size(iClassDataSet);
    
    % Copy the first niClassResampled1 examples into the first resampled
    % data set and the remaining examples into the second
    for iExample = 1:nExample
        if(iExample <= niClassResampled1(iClass))
            resampledDataSet1(iResampledExample1,:) = iClassDataSet(iExample,:);
            iResampledExample1 = iResampledExample1 + 1;
        else
            resampledDataSet2(iResampledExample2,:) = iClassDataSet(iExample,:);
            iResampledExample2 = iResampledExample2 + 1;
        end
    end

end

% Shuffle the resampled data sets as well
resampledDataSet1 = unsortMatrix(resampledDataSet1, 'r');
resampledDataSet2 = unsortMatrix(resampledDataSet2, 'r');
