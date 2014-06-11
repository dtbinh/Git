function result = needleTrackerTestAll(dataSetFile, controlVariabeString)

allFiles = dir;
nFile = size(allFiles, 1) - 2;

results = cell(1, nFile);
for iFile = 1:nFile
    results{iFile} = needleTrackerTest(allFiles(iFile+2).name, dataSetFile, controlVariabeString);
    if(strcmp(controlVariabeString, 'index'))
        results{iFile}{1} = iFile;
    end
end

controlVariable = zeros(1, nFile);
performance = zeros(1, nFile);
error = zeros(1, nFile);
for iFile = 1:nFile
    controlVariable(iFile) = results{iFile}{1};
    performance(iFile) = results{iFile}{2};
    error(iFile) = results{iFile}{3};
end

controlVariableSorted = zeros(1, nFile);
performanceSorted = zeros(1, nFile);
errorSorted = zeros(1, nFile);
for iFile = 1:nFile
    [~, index] = min(controlVariable);
    controlVariableSorted(iFile) = controlVariable(index);
    performanceSorted(iFile) = performance(index);
    errorSorted(iFile) = error(index);
    controlVariable(index) = max(controlVariable) + 1;
end

result = cell(1,2);
result{1} = controlVariableSorted;
result{2} = performanceSorted;
result{3} = errorSorted;


figure;
subplot(121);
plot(controlVariableSorted, performanceSorted);
xlabel(controlVariabeString);
ylabel('Performance');
subplot(122);
plot(controlVariableSorted, errorSorted);
xlabel(controlVariabeString);
ylabel('Pixel classification error');
