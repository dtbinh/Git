function window23 = newImageCropper(frame, center, cropsize)

% frame = rgb2gray(frame);
fillet = (cropsize-1)/2;
framesize = size(frame);
frame = [zeros(fillet,2*fillet+framesize(2)) ; zeros(framesize(1),fillet) frame zeros(framesize(1),fillet) ; zeros(fillet,2*fillet+framesize(2))];
center = round(center)+[fillet fillet];

window101 = frame(center(1)-fillet:center(1)+fillet,center(2)-fillet:center(2)+fillet);

window23 = imresize(window101, [23 23]);

