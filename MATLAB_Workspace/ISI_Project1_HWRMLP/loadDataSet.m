function trainingDataSet = loadDataSet(d_dataSetFile)

global nInput nOutput;

global numbers;

numbers = [0 1 2 3 4 5 6 7 8 9];

nInput = 16;
nOutput = 10;

dataSetMatrix = load(d_dataSetFile);
[nExample ~] = size(dataSetMatrix);

iValidExample = 1;

for iExample = 1:nExample
    numberIndex = find(numbers == dataSetMatrix(iExample,nInput+1));
    if(numberIndex > 0)
        inputMatrix(iValidExample, 1:nInput) = (dataSetMatrix(iExample, 1:nInput) / 50.0) - 1.0; 
        outputMatrix(iValidExample, 1:nOutput) = 0.1;
        outputMatrix(iValidExample, numberIndex) = 0.9;
        iValidExample = iValidExample + 1;
    end
end

trainingDataSet = cell(1,2);
trainingDataSet{1} = inputMatrix;
trainingDataSet{2} = outputMatrix;
