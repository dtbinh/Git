function unsortedMatrix = unsortMatrix(inputMatrix, direction)

[nRow nColumn] = size(inputMatrix);
unsortedMatrix = zeros(nRow, nColumn);

if(direction == 'r')
    randomNumbers = rand(1, nRow);
    for iRow = 1:nRow
        [~, randomIndex] = min(randomNumbers);
        unsortedMatrix(iRow, :) = inputMatrix(randomIndex,:);
        randomNumbers(randomIndex) = 2.0;
    end
    
elseif(direction == 'c')
    randomNumbers = rand(1, nColumn);
    for iColumn = 1:nColumn
        [~, randomIndex] = min(randomNumbers);
        unsortedMatrix(:, iColumn) = inputMatrix(:, randomIndex);
        randomNumbers(randomIndex) = 2.0;
    end
    
else
    unsortedMatrix = [];
    fprintf('Invalid option "%c" for "direction" - See "help unsort" for more information\n', direction);
end

