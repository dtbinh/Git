function rotatedVertices = rotateCuboid(vertices, U, angle, varargin)

% ROTATECUBOID Rotate a cuboid element
%    R = ROTATECUBOID(C,U,T) rotate the vertices of the cuboid C for T
%    degrees around the vector U. R is a cuboid matrix with the same size
%    as C.
%
%    R = ROTATECUBOID(C,U,T,'rad') consider the angle T in radians.
%
%    Other m-files required: rotationMatrix.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: CREATECUBOID, PLOTCUBOID, ROTATIONMATRIX

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 14-December-2013

% Default parameters
angleInDegrees = 1;

% Check varargin for updating the parameters
if(nargin > 3)
    if(strcmp(varargin{1}, 'rad'))
        angleInDegrees = 0;
    end
end

% Build the rotation matrix and apply it to the cuboid
if(angleInDegrees)
    rotatedVertices = rotationMatrix(deg2rad(angle), U) * vertices;
else
    rotatedVertices = rotationMatrix(angle, U) * vertices;
end