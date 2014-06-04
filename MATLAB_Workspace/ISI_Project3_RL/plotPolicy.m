function plotPolicy(policy)

% PLOTPOLICY Plot the movement policy
%    PLOTPOLICY(P) display a movement policy in the Windy Gridworld
%
%
%    Other m-files required: plotGridWorld.m
%    Subfunctions: decodeAction
%    MAT-files required: none
%
%    See also: PLOTGRIDWORLD, PLOTTRAJECTORY, INITPOLICY

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013

% Initialize the matrices to represent the actions of the policy
[nRow nColumn] = size(policy);
moveX = zeros(size(policy));
moveY = zeros(size(policy));

% Decode each action in X and Y movement components, for plotting with the
% quiver function
for i = 1:nRow
    for j = 1:nColumn
        [moveX(i,j) moveY(i,j)] = decodeAction(policy(i,j));
    end
end


% Plot the Gridworld
plotGridWorld(nRow, nColumn);

% Plot the policy
[xCoord yCoord] = meshgrid(1:nColumn, 1:nRow);
quiver(xCoord, yCoord, moveX, moveY, 'AutoScaleFactor', 0.4);



function [moveX moveY] = decodeAction(A)
% Convert an action code into X and Y movement components

switch(A)
    case 1
        moveY = -1; moveX =  0; % Movement in the N direction
    case 2
        moveY = -1; moveX =  1; % Movement in the NE direction
    case 3
        moveY =  0; moveX =  1; % Movement in the E direction
    case 4
        moveY =  1; moveX =  1; % Movement in the SE direction
    case 5
        moveY =  1; moveX =  0; % Movement in the S direction
    case 6
        moveY =  1; moveX = -1; % Movement in the SW direction
    case 7
        moveY =  0; moveX = -1; % Movement in the W direction
    case 8
        moveY = -1; moveX = -1; % Movement in the NW direction
end