function generateExtendedNeedleDataSet(originalDatasetFile, extendedDatasetFile, trainingRatio)

% Load the original dataset
originalDataset = load(originalDatasetFile);
inputMatrix = [originalDataset.trainingInput originalDataset.testInput];
outputMatrix = [originalDataset.trainingOutput originalDataset.testOutput];

% Measure the image size and the number of examples
[imageSize2 nExample] = size(inputMatrix);
imageSize = sqrt(imageSize2);

% Initialize the matrices for storing the extended dataset
extendedInputMatrix = zeros(imageSize2, 4*nExample);
extendedOutputMatrix = zeros(imageSize2, 4*nExample);
extendedInputMatrix(:, 1:nExample) = inputMatrix;
extendedOutputMatrix(:, 1:nExample) = outputMatrix;

% Populate the extended dataset matrices
for iAngle = 1:3
    for iExample = 1:nExample
        inputImage = reshape(inputMatrix(:,iExample), imageSize, imageSize);
        rotatedInputImage = imrotate(inputImage, iAngle*90, 'crop');
        extendedInputMatrix(:, iAngle*nExample + iExample) = reshape(rotatedInputImage, imageSize2, 1);
        
        outputImage = reshape(outputMatrix(:,iExample), imageSize, imageSize);
        rotatedOutputImage = imrotate(outputImage, iAngle*90, 'crop');
        extendedOutputMatrix(:, iAngle*nExample + iExample) = reshape(rotatedOutputImage, imageSize2, 1);
    end   
end

% Generate a dataset matrix by concatenating the input and output matrices
extendedDatasetMatrix = [extendedInputMatrix ; extendedOutputMatrix];

% Shuffle the dataset matrix
extendedDatasetMatrix = unsortMatrix(extendedDatasetMatrix, 'c');

% Split the dataset matrix into training and test matrices
nExample = 4*nExample;
trainingExamples = floor(nExample * trainingRatio);
extendedTrainingMatrix = extendedDatasetMatrix(:,1:trainingExamples);
extendedTestMatrix = extendedDatasetMatrix(:,trainingExamples+1:nExample);

% Separate the input and output components of the training and test
% matrices
trainingInput = extendedTrainingMatrix(1:imageSize2,:);
trainingOutput = extendedTrainingMatrix(imageSize2+1:2*imageSize2,:);
testInput = extendedTestMatrix(1:imageSize2,:);
testOutput = extendedTestMatrix(imageSize2+1:2*imageSize2,:);

% Save the generated matrices to the dataset file
save(extendedDatasetFile, 'trainingInput', 'trainingOutput', 'testInput', 'testOutput');
