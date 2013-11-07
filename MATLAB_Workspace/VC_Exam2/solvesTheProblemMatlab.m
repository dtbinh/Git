function solvesTheProblemMatlab(IL,IR,PL,PR)

%% Estimate f from PL, PR
f = estimateFundamentalMatrix(PL, PR, 'Method', 'Norm8Point');

%% Find the epipolar lines corresponding to PR and PL
eL = lineToBorderPoints(epipolarLine(f', PR), size(IL));
eR = lineToBorderPoints(epipolarLine(f, PL), size(IR));


%% Plot the original images and the epipolar lines
cvexShowImagePair(IL, IR, 'Image1', 'Image2', 'MultipleColors', PL, PR, eL, eR);

%% Find the transformations to rectify the image
[t1, t2] = estimateUncalibratedRectification(f, PL, PR, size(IR));

%% Transform only the images and the points

[ILT, PLT] = transformImagePoints(IL, PL, f, t1);
[IRT, PRT] = transformImagePoints(IR, PR, f, t2);

%% Estimate the new F using the new PR and PL
FT = estimateFundamentalMatrix(PLT, PRT, 'Method', 'Norm8Point');

%% Find the epipolar lines corresponding to PRT and PLT
eLT = lineToBorderPoints(epipolarLine(FT', PRT), size(ILT));
eRT = lineToBorderPoints(epipolarLine(FT, PLT), size(IRT));

%% Plot the rectified images and the epipolar lines
cvexShowImagePair(ILT, IRT, 'Image1', 'Image2', 'MultipleColors', PLT, PRT, eLT,eRT);























%==========================================================================
% Transform the image, corresponding points, and epipolar lines.
%==========================================================================
function [I, pts] = transformImagePoints(I, pts, f, t)

if isEpipoleInImage(f, size(I))
  error('vision:cvexShowStereoImages:epipoleInsideImage', ...
    ['The epipole is inside the image. You cannot apply the '...
     'transformation on the entire image.']);
end

htrans = vision.GeometricTransformer('TransformMatrixSource', 'Input port');
t = double(t);
I = step(htrans, I, t);

isXY = cvstGetCoordsChoice('fcnCvexShowImagePair');
if isXY
  t = convertGeometricTransform(t);
  pts = flipud(pts');
end

ptsr = bsxfun(@plus,  t(:,[1,2])*pts, t(:,3));
pts = bsxfun(@rdivide, ptsr([1,2],:), ptsr(3,:));

if isXY
  pts = fliplr(pts');  
end

%==========================================================================
function T = convertGeometricTransform(t)
T = t;
T(1,1) = t(2,2);
%T(1,2) = t(1,2);
T(1,3) = t(3,2);
%T(2,1) = t(2,1);
T(2,2) = t(1,1);
T(2,3) = t(3,1);
T(3,1) = t(2,3);
T(3,2) = t(1,3);
%T(3,3) = t(3,3);
