function findAndPlotEpipolarLines(imageLeft, imageRight, pointsLeft, pointsRight)

% FINDANDPLOTEPIPOLARLINES Find eipolar lines in stereo images
%    FINDANDPLOTEPIPOLARLINES(IL, IR, PL, PR) finds and plot a set of
%    eipolar lines in images IR and IL in respect to the matching points in
%    the other image, PL and PR. This is done by estimation of the
%    Fundamental Matrix and the location of the epipoles. 
%
%
%    Other m-files required: eightPoint.m, epipolesLocation.m,
%    generateEpipolarLines.m, plotImagePointsAndEpipolarLines.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: EIGHTPOINT, EPIPOLESLOCATION, GENERATEEPIPOLARLINES  

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 02-November-2013

imageLeftWidth = size(imageLeft,2);
imageRightWidth = size(imageRight,2);

F = eightPoint(pointsLeft, pointsRight);
F = F / F(3,3)
[epipoleLeft epipoleRight] = epipolesLocation(F);

leftEpipolarLines = generateEpipolarLines(F', pointsRight, imageLeftWidth);
rightEpipolarLines = generateEpipolarLines(F, pointsLeft, imageRightWidth);

plotImagePointsAndEpipolarLines(imageLeft, imageRight, pointsLeft, pointsRight, leftEpipolarLines, rightEpipolarLines)

fprintf('Left Epipole = (%d, %d); Right Epipole = (%d, %d)\n', round(epipoleLeft(1)), round(epipoleLeft(2)), round(epipoleRight(1)), round(epipoleRight(2)));