function [resampledDataSet1 resampledDataSet2] = resampleDataSet(dataSetFileName, percentage);

% Split the original data set separating the examples per class
splitDataSet = divideDataSet(dataSetFileName);

% Get the number of classes and the amount of data per example
[~, nClass] = size(splitDataSet);
[~, nData] = size(splitDataSet{1});

% Prepare arrays for calculating the amount of examples in the resampled
% matrices
niClassResampled1 = zeros(1, nClass);
niClassResampled2 = zeros(1, nClass);

for iClass = 1:nClass
    [niClass ~] = size(splitDataSet{iClass});
    niClassResampled1(iClass) = round(niClass * percentage);
    niClassResampled2(iClass) = niClass - niClassResampled1(iClass);
end

resampledDataSet1 = zeros(sum(niClassResampled1), nData);
resampledDataSet2 = zeros(sum(niClassResampled2), nData);

iResampledExample1 = 1;
iResampledExample2 = 1;

for iClass = 1:nClass
    
    iClassDataSet = unsortMatrix(splitDataSet{iClass}, 'r');
    [nExample ~] = size(iClassDataSet);
    
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

resampledDataSet1 = unsortMatrix(resampledDataSet1, 'r');
resampledDataSet2 = unsortMatrix(resampledDataSet2, 'r');
