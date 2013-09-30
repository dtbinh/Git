function plotCorners(image, cornerVertex, N)

% PLOTCORNERS Draw corners over an image
%    plotCorners(image, c) plots the image and draws a red square around 
%    each corner point described in c.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: CORNERS

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Plot the image
figure;
idisp(image, 'plain');
hold on;

% Iterate through all elements of cornerVertex
[~, nCorner] = size(cornerVertex);
for iCorner = 1:nCorner
    
    % Assign the coordinates of cornerVertex as the center of the square to
    % be drawn
    cy = cornerVertex(iCorner).i;
    cx = cornerVertex(iCorner).j;
    
    % Draw a red square of size (2N+1) centered in (cx,cy)
    x = [cx-N cx+N cx+N cx-N cx-N];
    y = [cy-N cy-N cy+N cy+N cy-N];
    plot(x,y,'r-');
    
end