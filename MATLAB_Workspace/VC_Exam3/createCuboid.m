function cuboid = createCuboid(X, Y, Z, L, H, W)

% CREATECUBOID Generate a matrix representing the vertices of a cuboid
%    C = CREATECUBOID(X,Y,Z,L,H,W) generates a cuboid of length L, height H
%    and width W, with its first vertex at the position (X,Y,Z). C is a 3x8
%    matrix containing the coordinates of each of the 8 vertices that
%    determine the cuboid
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: PLOTCUBOID, ROTATECUBOID

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 14-December-2013

cuboid = [X    Y    Z
          X    Y+H  Z
          X+L  Y+H  Z
          X+L  Y    Z
          X    Y    Z+W
          X    Y+H  Z+W
          X+L  Y+H  Z+W
          X+L  Y    Z+W]';