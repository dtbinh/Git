function [xNew yNew] = nextState(x, y, a, wind)

% NEXTSTATE Calculate the next state in a Windy Gridworld
%    [XNEW YNEW] = NEXTSTATE(X,Y,A,WIND) calculates the location (xNew, yNew)
%    on a windy gridwolrd, which is achieve departing from location (x,y)
%    and taking the action 'a'. The new location is also affected by the
%    wind, which causes a displacement in the -X direction. The velocity of
%    the wind varies in the Y direction. This means, that after calculating
%    the xNew and yNew coordinates, due to the action 'a', the X coordinate
%    is corrected such that xNew = xNew - wind(y). Even with the wind
%    displacement, the new location may not fall off the grid.
%
%    The action 'a' is a number between 1 and 8 representing a displacement
%    of 1 unit in the following directions {N, NE, E, SE, S, SW, W, NW}
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: INITVALUEFUNCTION, INITPOLICY, RANDOMVALIDACTION

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013



% Move the point (x,y) according to the action 'a'
switch(a)
    case 1 
        xNew = x-1; yNew = y  ;    % Movement in the N direction
    case 2
        xNew = x-1; yNew = y+1;    % Movement in the NE direction
    case 3
        xNew = x  ; yNew = y+1;    % Movement in the E direction
    case 4 
        xNew = x+1; yNew = y+1;    % Movement in the SE direction
    case 5 
        xNew = x+1; yNew = y  ;    % Movement in the S direction
    case 6 
        xNew = x+1; yNew = y-1;    % Movement in the SW direction
    case 7 
        xNew = x  ; yNew = y-1;    % Movement in the W direction
    case 8 
        xNew = x-1; yNew = y-1;    % Movement in the NW direction
end
         
% Move the point (x,y) according to the wind
xNew = max(1, xNew - wind(yNew));
