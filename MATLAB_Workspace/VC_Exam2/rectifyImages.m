function [ILT IRT PLT PRT] = rectifyImages(IL,IR,PL,PR)

% RECTIFYIMAGES Estimate the Fundamental Matrix 
%    F = EIGHTPOINT(PL, PR) estimates the Fundamental Matrix of a pair of
%    stereo images, using the matching points PL and PR.
%
%
%    Other m-files required: eightPoint.m, generateEpipolarLines.m,
%    plotImagePointsAndEpipolarLines.m, transformImageAndPoints.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: EIGHTPOINT, GENERATEEPIPOLARLINES,
%    ESTIMATEUNCALIBRATEDRECTIFICATION

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 05-November-2013

%% Estimate the Fundamental Matrix from PL, PR
F = eightPoint(PL, PR);
F = F / F(3,3);

%% Find the epipolar lines corresponding to PR and PL
eL = generateEpipolarLines(F', PR, size(IL,2));
eR = generateEpipolarLines(F, PL, size(IR,2));

%% Plot the original images and the epipolar lines
plotImagePointsAndEpipolarLines(IL, IR, PL, PR, eL, eR);

%% Find the transformations to rectify the image
[t1, t2] = estimateUncalibratedRectification(F, PL, PR, size(IR))

%% Transform the images and the matched points
[ILT, PLT] = transformImageAndPoints(IL, PL, t1);
[IRT, PRT] = transformImageAndPoints(IR, PR, t2);

%% Estimate the new F using the new PR and PL
FT = eightPoint(PLT, PRT);
FT = FT / FT(3,2)

%% Find the epipolar lines corresponding to PRT and PLT
eLT = generateEpipolarLines(FT', PRT, size(ILT,2));
eRT = generateEpipolarLines(FT, PLT, size(IRT,2));

%% Plot the rectified images and the new epipolar lines
plotImagePointsAndEpipolarLines(ILT, IRT, PLT, PRT, eLT, eRT);
