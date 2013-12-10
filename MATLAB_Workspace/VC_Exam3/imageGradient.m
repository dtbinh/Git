function [G1 G2] = imageGradient(I, varargin)

%
% FUNCTION DESCRIPTION
%

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 08-December-2013

% Verify if the output should be given in polar or rectangular coordinates
if(nargin == 1)
    polarCoordinates = 1;
else
    if(strcmp(varargin{1}, 'polar'))
        polarCoordinates = 1;
    else
        polarCoordinates = 0;
    end
end

% Generate the 3x3 Sobel matrices
sobelX = [-1 0 1; -2 0 2; -1 0 1];
sobelY = sobelX';

% Calculate the image gradient
Gx = iconv(I, sobelX,'same');
Gy = iconv(I, sobelY,'same');

% Assign the gradient components to the output variables
if(polarCoordinates)
    G1 = sqrt(Gx.^2 + Gy.^2);
    G2 = atan2(Gy, Gx);
else
    G1 = Gx;
    G2 = Gy;
end