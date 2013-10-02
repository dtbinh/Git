function unsortedMatrix = unsortMatrix(inputMatrix, direction)

% UNSORTMATRIX Shuffles data from matrix
%    S = unsortMatrix(A, 'r') generates the matrix S by shuffling the entire
%    rows of the matrix A.
%
%    S = unsortMatrix(A, 'c') generates the matrix S by shuffling the entire
%    columns of the matrix A.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: RESAMPLEDATASET, RESAMPLEDATASETANDSAVE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Measure the size of the input matrix
[nRow nColumn] = size(inputMatrix);

% Initialize the output matrix
unsortedMatrix = zeros(nRow, nColumn);

% Option 'r' : Shuffle entire rows
if(direction == 'r')
    randomNumbers = rand(1, nRow);
    for iRow = 1:nRow
        [~, randomIndex] = min(randomNumbers);
        unsortedMatrix(iRow, :) = inputMatrix(randomIndex,:);
        randomNumbers(randomIndex) = 1.0;
    end

% Option 'c' : Shuffle entire columns
elseif(direction == 'c')
    randomNumbers = rand(1, nColumn);
    for iColumn = 1:nColumn
        [~, randomIndex] = min(randomNumbers);
        unsortedMatrix(:, iColumn) = inputMatrix(:, randomIndex);
        randomNumbers(randomIndex) = 1.0;
    end
    
% Invalid option - display an error message and return an empty matrix    
else
    unsortedMatrix = [];
    fprintf('Invalid option "%c" for "direction" - See "help unsort" for more information\n', direction);
end

