function splitDataSet = divideDataSet(dataSet)

nClass = 10;
[nExample nData] = size(dataSet);

splitDataSet = cell(1, nClass);
classCounter = ones(1, nClass);

for iExample = 1:nExample
    exampleClass = dataSet(iExample, nData) + 1;
    splitDataSet{exampleClass}(classCounter(exampleClass), :) = dataSet(iExample, :);
    classCounter(exampleClass) = classCounter(exampleClass) + 1;
end
    