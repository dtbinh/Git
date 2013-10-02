function saveDataSet(dataSet, outputFileName)

% SAVEDATASET Save data set to file
%    saveDataSet(dataSet, outputFileName) saves the given 
%    dataSet as text into the output file. The dataSet must be provided in
%    a single matrix (not in the cell-array mode) of size NxM where N is
%    the number of examples in the data set and M is the number of data per
%    example. Typically M = number_of_inputs + 1, for most of the pattern
%    recognition problems. 
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: LOADDATASET, RESAMPLEDATASET, RESAMPLEDATASETANDSAVE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Open the output file
outputFile = fopen(outputFileName, 'w+');

% Measure the amount of examples in the data set
[nExample1, nData] = size(dataSet);

% Iterate for every example in the data set
for iExample = 1:nExample1
    
    % Write each data of the example followed by a ',' character
    % The data is prepended with spaces in order to align all ','
    % characters and increase readability
    for iData = 1:nData-1
        if(dataSet(iExample, iData) < 10)
            fprintf(outputFile, '  %d,', dataSet(iExample, iData));
        elseif(dataSet(iExample, iData) < 100)
            fprintf(outputFile, ' %d,', dataSet(iExample, iData));
        else
            fprintf(outputFile, '%d,', dataSet(iExample, iData));
        end
    end
    
    % For the last data of the example, write it without the ','
    if(dataSet(iExample, nData) < 10)
        fprintf(outputFile, '  %d\n', dataSet(iExample, nData));
    elseif(dataSet(iExample, nData) < 100)
        fprintf(outputFile, ' %d\n', dataSet(iExample, nData));
    else
        fprintf(outputFile, '%d\n', dataSet(iExample, nData));
    end
    
end

% Close the output file
fclose(outputFile);