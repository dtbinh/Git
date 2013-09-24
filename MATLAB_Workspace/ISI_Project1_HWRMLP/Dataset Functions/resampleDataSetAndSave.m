function resampleDataSetAndSave(inputDataSetFile, resampledFile1, resampledFile2, percentage)

inputDataSet = load(inputDataSetFile);
[resampledDataSet1 resampledDataSet2] = resampleDataSet(inputDataSet, percentage);
saveDataSet(resampledDataSet1, resampledFile1);
saveDataSet(resampledDataSet2, resampledFile2);
