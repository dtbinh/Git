function generateNeedleDataset(inputDir, outputDir, datasetFileName, trainingRatio)

% Find all files in the input directory
inputFiles = dir(inputDir);
nInput = size(inputFiles, 1) - 2;

% Read one image for measuring its size
testImageName = sprintf('%s/%s',inputDir, inputFiles(3).name);
testImage = iread(testImageName);
imageSize = size(testImage, 1);
imageSize2 = imageSize^2;

% Generate the input matrix containing all images in the input directory
% (each image is reshaped to a column array)
inputMatrix = zeros(imageSize2, nInput);
for iFile = 1:nInput
    imageName = sprintf('%s/%s',inputDir, inputFiles(iFile+2).name);
    image = iread(imageName, 'grey', 'double');
    [m n] = size(image);
    
    if(m ~= imageSize || n ~= imageSize)
        fprintf('ERROR: Image %s size is incorrect! Expected (%d,%d), but found (%d,%d)\n', imageName, imageSize, imageSize, m, n);
    else
        inputMatrix(:, iFile) = reshape(image, imageSize2, 1);
    end
end

% Find all files in the output directory
outputFiles = dir(outputDir);
nOutput = size(outputFiles, 1) - 2;

% Generate the output matrix containing all images in the output directory
% (each image is reshaped to a column array)
outputMatrix = zeros(imageSize2, nOutput);
for iFile = 1:nOutput
    imageName = sprintf('%s/%s',outputDir, outputFiles(iFile+2).name);
    image = iread(imageName, 'grey', 'double');
    [m n] = size(image);
    
    if(m ~= imageSize || n ~= imageSize)
        fprintf('ERROR: Image %s size is incorrect! Expected (%d,%d), but found (%d,%d)\n', imageName, imageSize, imageSize, m, n);
    else
        outputMatrix(:, iFile) = reshape(image, imageSize2, 1);
    end
end

% Generate a dataset matrix by concatenating the input and output matrices
datasetMatrix = [inputMatrix ; outputMatrix];

% Shuffle the dataset matrix
datasetMatrix = unsortMatrix(datasetMatrix, 'c');

% Split the dataset matrix into training and test matrices
nExample = size(datasetMatrix, 2);
trainingExamples = floor(nExample * trainingRatio);
trainingMatrix = datasetMatrix(:,1:trainingExamples);
testMatrix = datasetMatrix(:,trainingExamples+1:nExample);

% Separate the input and output components of the training and test
% matrices
trainingInput = trainingMatrix(1:imageSize2,:);
trainingOutput = trainingMatrix(imageSize2+1:2*imageSize2,:);
testInput = testMatrix(1:imageSize2,:);
testOutput = testMatrix(imageSize2+1:2*imageSize2,:);

% Save the generated matrices to the dataset file
save(datasetFileName, 'trainingInput', 'trainingOutput', 'testInput', 'testOutput');
