function plotTrajectory(policy, start, goal, wind)

% PLOTTRAJECTORY Plot a trajectory from start to goal in the Windy Gridworld
%    PLOTTRAJECTORY(P,S,G,W) perform and plot a trajectory in the Windy
%    Gridworld going from the start to the goal locations, following the
%    actions described in the policy. The wind displacements are also taken
%    in account.
%
%
%    Other m-files required: plotGridWorld.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: PLOTGRIDWORLD, PLOTPOLICY, INITPOLICY

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013


% Move to the start location
x = start(1);
y = start(2);
iPlot = 1;
maxSteps = 1000;

% Move through the Gridworld until reaching the goal location
while(~(x == goal(1) && y == goal(2)))
    
    % Save each passed location for plotting
    xPlot(iPlot) = x;
    yPlot(iPlot) = y;
    iPlot = iPlot+1;
    
    % Move to the next state according to the policy
    [x y] = nextState(x, y, policy(x,y), wind);
    
    if(iPlot == maxSteps)
        break;
    end
end

if(iPlot < maxSteps)
    
    % Add the goal location at the end of the plotting arrays
    xPlot(iPlot) = goal(1);
    yPlot(iPlot) = goal(2);
    
    % Plot the Gridworld
    [nRow nColumn] = size(policy);
    plotGridWorld(nRow, nColumn, [start(1) start(2)], [goal(1) goal(2)]);
    
    % Plot the performed trajectory
    plot(yPlot, xPlot, 'b*-');
    
else
    fprintf('Unable to find a valid trajectory using the provided Policy \n');
end
