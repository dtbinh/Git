function epipolarLine = generateEpipolarLines(F, points, imageWidth)

% GENERATEEPIPOLARLINES Find a set of epipolar lines that match a given set of points
%
%    L = GENERATEEPIPOLARLINES(F, P, W) finds the coordinates of the
%    epipolar lines in one image, that match the points P in the other
%    image, by using the system Fundamental Matrix. W is the width of the
%    image where the epipolar lines are suposed to be found.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: FINDANDPLOTEPIPOLARLINES, EPIPOLESLOCATION, EIGHTPOINT, E2H  

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 02-November-2013

%%  Convert the points to homogeneous coordinates
nPoint = size(points,1);
points = e2h(points');

%% Find the coordinates of the corresponding epipolar lines
lineCoordinates = (points' * F')';

%% Find the extremities of the line in the image axis
epipolarLine = zeros(nPoint, 4);
lineX = [1 imageWidth];
for i = 1:nPoint
     lineY = (-lineCoordinates(3,i)-lineCoordinates(1,i)*lineX)/lineCoordinates(2,i);
     epipolarLine(i,:) = [lineX lineY];
end
