function edges = edgeDirection(image, mask, theta)

% Applies the first derivate over the 'image', using the provided high-pass
% filter 'mask'. The derivate is applie both in X and Y directions and the
% returned image is a composition of these components, representing the
% derivate along an arbitrary direction. When theta = 0, the returned image
% is the derivate in the X direction

verticalEdges = myFilter(image, mask, 'double');
horizontalEges = myFilter(image, mask', 'double');

magnitude = sqrt(verticalEdges.^2 + horizontalEges.^2);
angle = atan2(horizontalEges, verticalEdges);

newAngle = angle - deg2rad(theta);
[r c] = size(newAngle);
for i = 1:r
    for j = 1:c
        if(newAngle(i,j) > pi/2.0)
            newAngle(i,j) = newAngle(i,j) - pi;
        elseif(newAngle(i,j) < -pi/2.0)
            newAngle(i,j) = newAngle(i,j) + pi;
        end
    end
end

edges = uint8(magnitude .* cos(newAngle));



