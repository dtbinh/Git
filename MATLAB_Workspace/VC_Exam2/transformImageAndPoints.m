function [I, pts] = transformImageAndPoints(I, pts, t)

htrans = vision.GeometricTransformer('TransformMatrixSource', 'Input port');
t = double(t);
I = step(htrans, I, t);

t = convertGeometricTransform(t);
pts = flipud(pts');
ptsr = bsxfun(@plus,  t(:,[1,2])*pts, t(:,3));
pts = bsxfun(@rdivide, ptsr([1,2],:), ptsr(3,:));
pts = fliplr(pts');
end

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
end
