function saveDataSet(dataSet, outputFileName)

outputFile = fopen(outputFileName, 'w+');
[nExample1, nData] = size(dataSet);
for iExample = 1:nExample1
    for iData = 1:nData-1
        if(dataSet(iExample, iData) < 10)
            fprintf(outputFile, '  %d,', dataSet(iExample, iData));
        elseif(dataSet(iExample, iData) < 100)
            fprintf(outputFile, ' %d,', dataSet(iExample, iData));
        else
            fprintf(outputFile, '%d,', dataSet(iExample, iData));
        end
    end
    
    if(dataSet(iExample, nData) < 10)
        fprintf(outputFile, '  %d\n', dataSet(iExample, nData));
    elseif(dataSet(iExample, nData) < 100)
        fprintf(outputFile, ' %d\n', dataSet(iExample, nData));
    else
        fprintf(outputFile, '%d\n', dataSet(iExample, nData));
    end
    
end

fclose(outputFile);