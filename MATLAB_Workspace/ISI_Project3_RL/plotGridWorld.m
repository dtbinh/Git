function plotGridWorld(nRow, nColumn, varargin)

% PLOTGRIDWORLD Plot the Windy Gridworld
%    PLOTGRIDWORLD(M,N) plots a grid world of MxN grid cells. Also mark the
%    start and goal locations in the grid.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: PLOTTRAJECTORY, PLOTPOLICY

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013


% Create a new Figure and configure the axes properties
figure;
hold on;
set(gca,'YDir','Reverse')
set(gca,'position',[0 0 1.1 1],'units','normalized')
set(gca,'xtick',[])
set(gca,'ytick',[])

% Draw the grid
for iColumn = 1:nColumn+1
    plot([iColumn-0.5 iColumn-0.5], [0.5 nRow+0.5], 'k-');
end

for iRow = 1:nRow+1
    plot([0.5 nColumn+0.5], [iRow-0.5 iRow-0.5], 'k-');
end

% Draw the start and goal location markers
if(nargin > 2)
    plot(varargin{1}(2), varargin{1}(1), 'rd', 'MarkerSize', 15, 'LineWidth', 4);
    plot(varargin{2}(2), varargin{2}(1), 'rx', 'MarkerSize', 20, 'LineWidth', 5);
end
