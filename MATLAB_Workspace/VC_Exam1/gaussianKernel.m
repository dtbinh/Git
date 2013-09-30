function gaus = gaussianKernel(sigma, N)

% GAUSSIANKERNEL Generate a discrete gaussian kernel
%    gaus = gaussianKernel(sigma, N) is a NxN matrix that represents a
%    discrete approximation of a bidimensional Gaussian with zero mean and 
%    standard deviation equals to 'sigma'.
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also:

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013


% Initialize matrix for storing the bidimensional Gaussian
gaus = double(ones(N));

% gaus(c,c) -> center (peak) of the Gaussian
c = (N+1)/2;

% Generate a non-normalized Gaussian g(x) = exp( -x² /2*sigma²)
for i = 1:N
    for j = 1:N
        if(i ~= c || j ~= c)
            x2 = (i-c)^2 + (j-c)^2;
            gaus(i,j) = exp( - x2 / (2*sigma^2));
        end
    end
end

% Normalized the generated Gaussian
gaus = gaus / sum(sum(gaus));