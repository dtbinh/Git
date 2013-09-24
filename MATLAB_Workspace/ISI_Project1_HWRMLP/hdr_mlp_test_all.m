function result = hdr_mlp_test_all(dataSetFile, outputFile)

allFiles = dir;
[nFile ~] = size(allFiles);
nMatFile = nFile - 2;

matFiles = cell(nMatFile,1);

for iFile = 1:nMatFile
    matFiles{iFile} = allFiles(iFile+2).name;
end

results = cell(1, nFile);

for iFile = 1:nMatFile
    results{iFile} = hdr_mlp_test(dataSetFile, matFiles{iFile});
end

controlVariable = zeros(1,nMatFile);
networkError = zeros(1,nMatFile);
networkMissRate = zeros(1,nMatFile);

for iFile = 1:nMatFile
    controlVariable(iFile) = results{iFile}{1};
    networkError(iFile) = results{iFile}{2};
    networkMissRate(iFile) = results{iFile}{3};
end

controlVariableSorted = zeros(1,nMatFile);
networkErrorSorted = zeros(1,nMatFile);
networkMissRateSorted = zeros(1,nMatFile);

for iFile = 1:nMatFile
    [~, index] = min(controlVariable);
    controlVariableSorted(iFile) = controlVariable(index);
    networkErrorSorted(iFile) = networkError(index);
    networkMissRateSorted(iFile) = networkMissRate(index);
    controlVariable(index) = max(controlVariable) + 1;
end

figure;
subplot(1,2,1);
plot(controlVariableSorted, networkErrorSorted);
subplot(1,2,2);
plot(controlVariableSorted, networkMissRateSorted);

if(~strcmp(outputFile,'none'))
    save(outputFile, 'controlVariableSorted', 'networkErrorSorted', 'networkMissRateSorted', 'dataSetFile', 'matFiles');
end

result = cell(1,3);
result{1} = controlVariableSorted;
result{2} = networkErrorSorted;
result{3} = networkMissRateSorted;