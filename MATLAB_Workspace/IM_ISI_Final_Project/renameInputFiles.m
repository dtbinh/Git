function [inputFileNumber outputFileNumber inputFileValid] = renameInputFiles(outputDir)

outputFiles = dir(outputDir);
nOutput = size(outputFiles, 1);

outputFileNumber = zeros(1,nOutput-2);
outputFileIndex = 1;

for iFile = 1:nOutput
    fileName = outputFiles(iFile).name;
    length = size(fileName,2);
    if(length > 2)
        outputFileNumber(outputFileIndex) = str2num(fileName(9:length-5));
        outputFileIndex = outputFileIndex + 1;
    end
end

inputFiles = dir();
nInput = size(inputFiles, 1);

inputFileNumber = zeros(1,nInput-2);
inputFileIndex = 1;

inputFileValid = zeros(1,nInput-2);
inputFileIndex = 1;

for iFile = 1:nInput
    fileName = inputFiles(iFile).name;
    length = size(fileName,2);
    if(length > 2)
        inputFileNumber(inputFileIndex) = str2num(fileName(2:length-5));
        
        
        if(size(find(outputFileNumber == inputFileNumber(inputFileIndex)),2) == 1)
            inputFileValid(inputFileIndex) = 1;
        else
            inputFileValid(inputFileIndex) = 0;
        end
        
        inputFileIndex = inputFileIndex + 1;
    end
end

for iFile = 1:nInput
    fileName = inputFiles(iFile).name;
    length = size(fileName,2);
    if(length > 2)
        fileNumber = str2num(fileName(2:length-5));
        [r c] = find(inputFileNumber == fileNumber);
        if(inputFileValid(r,c) == 1)
            if(fileNumber > 999)
                newFileName = sprintf('input_(%d).jpg', fileNumber);
            elseif(fileNumber > 99)
                newFileName = sprintf('input_(0%d).jpg', fileNumber);
            elseif(fileNumber > 9)
                newFileName = sprintf('input_(00%d).jpg', fileNumber);
            else
                newFileName = sprintf('input_(000%d).jpg', fileNumber);
            end
            dos(['rename "' fileName '" "' newFileName '"']);               
        end
        
    end
end



% inputFiles = dir();
% nInput = size(inputFiles, 1);
% 
% for iFile = 1:nInput
%     fileName = inputFiles(iFile).name;
%     length = size(fileName,2);
%     if(length > 2)
%         inputFileNumber = str2num(fileName(2:length-5));
%         if(size(find(outputFileNumber == inputFileNumber),2) == 1)
%             
%             if(inputFileNumber > 999)
%                 newFileName = sprintf('input_(%d).jpg', inputFileNumber);
%             elseif(inputFileNumber > 99)
%                 newFileName = sprintf('input_(0%d).jpg', inputFileNumber);
%             elseif(inputFileNumber > 9)
%                 newFileName = sprintf('input_(00%d).jpg', inputFileNumber);
%             else
%                 newFileName = sprintf('input_(000%d).jpg', inputFileNumber);
%             end
%             dos(['rename "' fileName '" "' newFileName '"']);            
%             
%         end
%     end
% end
