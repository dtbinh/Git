function R = rotationMatrix(angle, U)

% ROTATIONMATRIX Build a generic rotation matrix
%    R = ROTATIONMATRIX(T,U) builds a generic 3x3 rotation matrix
%    representing a rotation of T degrees (in radians) around the vector U.
%
%    Other m-files required: rotationMatrix.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: ROTATECUBOID

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 14-December-2013

R = [(cos(angle)+U(1)^2*(1-cos(angle)))         (U(1)*U(2)*(1-cos(angle))-U(3)*sin(angle)) (U(1)*U(3)*(1-cos(angle))+U(2)*sin(angle)) ;
     (U(1)*U(2)*(1-cos(angle))+U(3)*sin(angle)) (cos(angle)+U(2)^2*(1-cos(angle)))         (U(2)*U(3)*(1-cos(angle))-U(1)*sin(angle)) ;
     (U(1)*U(3)*(1-cos(angle))-U(2)*sin(angle)) (U(2)*U(3)*(1-cos(angle))+U(1)*sin(angle)) (cos(angle)+U(3)^2*(1-cos(angle)))        ];