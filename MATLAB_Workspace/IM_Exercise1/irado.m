function reconstructedImage = irado(sinogram, method)

% IRADO Reconstruct an image from its sinogram
%    I = irado(sinogram, method) applies an image reconstruction algorithm
%    over the sinogram, generating the reconstructed image I. The parameter
%    'method' selects which algorithm is going to be used. The options for
%    'method' are:
%           'normal'   - back   projection algorithm
%           'filtered' - filtered back projection algorithm
%
%
%  Other m-files required: imageCrop.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: RADO, IRADON, IMAGECROP, IMROTATE, FIR2

% Authors: André Augusto Geraldes e Thiago Silva Rocha
% Emails: andregeraldes@lara.unb.br; rochasilvathiago@lara.unb.br
% October 2013; Last revision: 21-October-2013


% [hard-coded parameter] The order of the high-pass filter
filterOrder = 10000;

% Calculate the number of projections and the projection size
[nProjection projectionSize] = size(sinogram);

% Initialize the matrix to store the back projected image
backProjectedImage = zeros(projectionSize, projectionSize);

% In 'filtered' mode, applies a high-pass ramp filter to each projection
if(strcmp(method, 'filtered'))
    filter = fir2(filterOrder,[0 1], [0 1]);
    for iProjection = 1:nProjection
        sinogram(iProjection,:) = conv(sinogram(iProjection,:), filter, 'same');
    end
end

% For each projection in the sinogram:
for iProjection = 1:nProjection
    
    % Back project the current projection in the according angle
    angle = (180 * iProjection-1)/ nProjection;
    backProjection = repmat(sinogram(iProjection,:), projectionSize,1);
    angularBackProjection = imrotate(backProjection, angle, 'bilinear', 'crop');
    
    % Add the current back projection to the back projected image
    backProjectedImage = backProjectedImage + angularBackProjection;
    
end

% Crop the useless borders of the reconstructed image
reconstructedImage = imageCrop(backProjectedImage, sqrt(2));