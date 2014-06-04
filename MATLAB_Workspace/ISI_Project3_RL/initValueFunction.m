function Q = initValueFunction(xMax, yMax)

% INITVALUEFUNCTION Initialize a value function matrix for the Windy Gridworld
%    Q = INITVALUEFUNCTION(XMAX,YMAX) is a matriz 3D matrix containing the
%    values associated to all combinations of state (x,y) and action (a) in
%    the Windy Gridworld. The invalid combinations (the ones that would
%    move the point off the grid) are initialized with a value of
%    -Infinity. All the remaining values are initialized as 0.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: INITPOLICY, RANDOMVALIDACTION

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013


% Initialize an empty 3D matriz for storing the value function Q
Q = zeros(xMax, yMax, 8);

% Assign -Inf to all invalid combinations of state-action

% Top border restriction
for iColumn = 1:yMax
    Q(1, iColumn, 1) = -inf;
    Q(1, iColumn, 2) = -inf;
    Q(1, iColumn, 8) = -inf;
end

% Bottom border restriction
for iColumn = 1:yMax
    Q(xMax, iColumn, 4) = -inf;
    Q(xMax, iColumn, 5) = -inf;
    Q(xMax, iColumn, 6) = -inf;
end

% Left border restriction
for iRow = 1:xMax
    Q(iRow, 1, 6) = -inf;
    Q(iRow, 1, 7) = -inf;
    Q(iRow, 1, 8) = -inf;
end

% Right border restriction
for iRow = 1:xMax
    Q(iRow, yMax, 2) = -inf;
    Q(iRow, yMax, 3) = -inf;
    Q(iRow, yMax, 4) = -inf;
end
