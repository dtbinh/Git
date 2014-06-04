function action = randomValidAction(x, y, xMax, yMax)

% RANDOMVALIDACTION Randomly select a valid action in the Windy Gridworld
%    A = RANDOMVALIDACTION(X,Y,XMAX,YMAX) selects a random action that can
%    be applied to the state (X,Y), without making it fall of the grid. The
%    action A is a number between 1 and 8 representing a displacement of 1
%    unit in the following directions {N, NE, E, SE, S, SW, W, NW}
%
%
%    Other m-files required: randArgMax.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: RANDARGMAX, INITPOLICY

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013


% Generate an array with all existing actions
possibleActions = ones(1,8);

% Top border restriction
if(x == 1)
    possibleActions(8) = 0;
    possibleActions(1) = 0;
    possibleActions(2) = 0;
    
% Bottom border restriction    
elseif(x == xMax)
    possibleActions(4) = 0;
    possibleActions(5) = 0;
    possibleActions(6) = 0;
end

% Left border restriction
if(y == 1)
    possibleActions(6) = 0;
    possibleActions(7) = 0;
    possibleActions(8) = 0;
    
% Right border restriction    
elseif(y == yMax)
    possibleActions(2) = 0;
    possibleActions(3) = 0;
    possibleActions(4) = 0;
end

% Randomly select one of the remaining actions
action = randArgMax(possibleActions);