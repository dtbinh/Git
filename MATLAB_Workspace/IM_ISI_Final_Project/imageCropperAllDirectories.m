function imageCropperAllDirectories(sourceDir, targetDir)

% Find the content of the targetDirectory
dirInfo = dir(sourceDir);

% Remove the '.' and '..' elements from the list
dirItens = size(dirInfo,1);
dirInfo2 = dirInfo(3:dirItens)';

% Verify which of these elements are directories
dirFlags = [dirInfo2.isdir];
dirIndexes = find(dirFlags == 1);
nDir = size(dirIndexes,2);

% Run the function imageCropper for each found directory
for iDir = 1:nDir
    currentDir = sprintf('%s/%s', sourceDir, dirInfo2(dirIndexes(iDir)).name);
    imageCropper(currentDir, targetDir);
    uiwait(imageCropper(currentDir, targetDir));
end



