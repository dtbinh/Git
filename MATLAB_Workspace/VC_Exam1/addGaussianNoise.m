function noisyImage = addGaussianNoise(image, SNR)

% ADDGAUSSIANNOISE Adds white Gaussian noise to image
%    noisyImage = addGaussianNoise(image, SNR) is the result of adding
%    a white Gaussian noise to the original image. The noise intensity is
%    adjusted so that the resulting Signal-Noise-Ratio matches SNR.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: ADDSALTANDPEPPERNOISE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

%% Generate white Gaussian noise and adjust its SNR

% Generate a random white Gaussian noise
noise = randn(size(image));

% Adjust the noise SNR to match snr
stdNoise = std2(noise);
stdImage = std2(double(image));
noise = noise * stdImage / (stdNoise * SNR);

%% Add the generated noise to the original image

noisyImage = uint8(double(image) + noise);