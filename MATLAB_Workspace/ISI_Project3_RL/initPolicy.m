function P = initPolicy(xMax, yMax)

% INITPOLICY Initialize a random policy for moving in the Windy Gridworld
%    P = INITPOLICY(XMAX,YMAX) is a matriz of dimensions [XMAX YMAX]
%    containing values between 1 and 8, which correspond to all of the
%    King's moves in the Windy Gridworld. The values are selectedly
%    randomly, but consistenly so that no action in the policy P causes an invalid
%    state.
%
%
%    Other m-files required: randomValidAction.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: RANDOMVALIDACTION, RANDARGMAX, INITVALUEFUNCTION

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013



% Initialize an empty matriz for storing the policy
P = zeros(xMax, yMax);

for iRow = 1:xMax
    for iColumn = 1:yMax
        
        % For each state, select one random valid action
        P(iRow, iColumn) = randomValidAction(iRow, iColumn, xMax, yMax);
    end
end


