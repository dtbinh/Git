function croppedImage = imageCrop(I, scale)

% IMAGECROP Crops an image
%    croppedImage = imageCrop(I, scale) crops the borders of the image
%    I, in such a way that the resulting image width/height is 1/scale 
%    times the original image width/height.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: IMAGEPAD

% Authors: André Augusto Geraldes e Thiago Silva Rocha
% Emails: andregeraldes@lara.unb.br; rochasilvathiago@lara.unb.br
% October 2013; Last revision: 21-October-2013 


% Calculate the size of the original image (if the image is not square, the
% largest dimension is considered)
[r c] = size(I);
imageWidth = max(r,c);

% Calculate the size of the padded image
croppedImageWidth = imageWidth / scale;

% Calculate the cropped margin width/height
offset = round((imageWidth - croppedImageWidth)/2);

% Generate the cropped image
croppedImage = I(offset:offset+croppedImageWidth-1, offset:offset+croppedImageWidth-1);