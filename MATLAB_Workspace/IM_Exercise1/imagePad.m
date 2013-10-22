function paddedImage = imagePad(I, scale)

% IMAGEPAD Creates a black pad for an image
%    paddedImage = imagePad(I, scale) adds a black pad scaled by SCALE
%    to an image I with the image in the center.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: IMAGECROP

% Authors: André Augusto Geraldes e Thiago Silva Rocha
% Emails: andregeraldes@lara.unb.br; rochasilvathiago@lara.unb.br
% October 2013; Last revision: 21-October-2013


% Calculate the size of the original image (if the image is not square, the
% largest dimension is considered)
[r c] = size(I);
imageWidth = max(r,c);

% Calculate the size of the padded image
paddedImageWidth = imageWidth * scale;

% Calculate the margin width/height
offset = round((paddedImageWidth - imageWidth)/2);

% Generate the padded image
paddedImage = zeros(scale*imageWidth);
paddedImage(offset:offset+imageWidth-1, offset:offset+imageWidth-1) = I;