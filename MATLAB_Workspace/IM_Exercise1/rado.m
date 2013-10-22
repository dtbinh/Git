function  sinogram = rado(I, nProjection)

% RADO Generates the sinogram of an image
%    sinogram = RADO(I, nProjection) applies the Radon Transform for a 2-D 
%    image I, using nProjection equally spaced projections between 0º and 
%    180º.
%
%
%  Other m-files required: imagePad.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: RADON, IMAGEPAD, IMROTATE

% Authors: André Augusto Geraldes e Thiago Silva Rocha
% Emails: andregeraldes@lara.unb.br; rochasilvathiago@lara.unb.br
% October 2013; Last revision: 21-October-2013


% Extended the original image to avoid losing information when using
% imrotate
I = imagePad(I, sqrt(2));

% Initialize the matrix to store the generated sinogram
sinogram = zeros(nProjection, size(I,1));

% For each projection:
for iProjection = 1:nProjection
    
    % Rotate the original image, in order to simulate the CT scanner
    % rotation
    theta = (iProjection-1) * (180.0/nProjection);
    projection = imrotate(I, -theta, 'bilinear', 'crop');
    
    % Calculate the image projection in the given direction
    sinogram(iProjection,:) = sum(projection);
end