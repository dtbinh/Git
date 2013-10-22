function shapes = rangeSurfPatches(rangeImage)

% RANGESURFPATCHES Algorithm RANGE_SURF_PATCHES (E. Trucco, page 88)
%    S = rangeSurfPatches(rangeImage) applies the H-K segmentation
%    algorithm to the given range Image.
%
%
%  Other m-files required: gaussianFilter.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: POINTCLOUD2DEPTHIMAGE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

%% Apply Gaussian smoothing to the image

% [hard-coded parameter] window size and standard deviation of the Gaussian
gaussianSigma = 1;
gaussianWindow = 5;

% [hard-coded parameter] Thresholds to round small values of K and H
threshold = 10^(-3);
Kthreshold = threshold;
Hthreshold = threshold;

% Apply Gaussian smoothing
filteredImage = gaussianFilter(rangeImage, gaussianSigma, gaussianWindow);

%% Compute the image derivatives

prewitt = [1 1 1; 0 0 0; -1 -1 -1];
Ix = iconv(double(filteredImage), double(prewitt'),'same');
Iy = iconv(double(filteredImage), double(prewitt),'same');
Ixx = iconv(Ix, double(prewitt'),'same');
Iyy = iconv(Iy, double(prewitt),'same');
Ixy = iconv(Ix, double(prewitt),'same');

%% Calculate the matrices K and H

% Initialize the matrices for storing the values of K and H
[nRow nColumn] = size(rangeImage);
K = zeros(nRow, nColumn);
H = zeros(nRow, nColumn);

for i = 1:nRow
    for j = 1:nColumn
        
        hx = Ix(i,j);   hy = Iy(i,j);
        hxx = Ixx(i,j); hyy = Iyy(i,j); hxy = Ixy(i,j);
       
        K(i,j) = (hxx*hyy - hxy^2) / (1+hx^2+hy^2)^2 ;
        H(i,j) = ((1+hx^2)*hyy - 2*hx*hy*hxy + (1+hy^2)*hxx) / (2*(1+hx^2+hy^2)^(3/2)) ;
        
    end
end

% Round the small values of K and H to 0
K(abs(K) < Kthreshold) = 0;
H(abs(H) < Hthreshold) = 0;

%% Classifiy each pixel of the range image according to the values of H and K

shapes = zeros(nRow, nColumn);
for i = 1:nRow
    for j = 1:nColumn
        
        % Hyperbolic
        if(K(i,j) < 0)                     shapes(i,j) = 1;
            
        % Convex cylindrical
        elseif(K(i,j) == 0 && H(i,j) < 0)  shapes(i,j) = 2;
            
        % Plane
        elseif(K(i,j) == 0 && H(i,j) == 0) shapes(i,j) = 3;
            
        % Concave cylindrical
        elseif(K(i,j) == 0 && H(i,j) > 0)  shapes(i,j) = 4;
            
        % Convex eliptic
        elseif(K(i,j) >  0 && H(i,j) < 0)  shapes(i,j) = 5;
            
        % Concave eliptic
        elseif(K(i,j) >  0 && H(i,j) > 0)  shapes(i,j) = 6;
            
        % If none of the above conditins apply, shapes(i,j) = 0 (undefined)
        end
        
    end
end
