function d = featurePointMatch(imageFile1, imageFile2, pointsFile, varargin)

% FEATUREPOINTMATCH Estimate the discrete optical flow (E. Trucco, page 199) 
%    D = FEATUREPOINTMATCH(I1, I2, P) calculates the optical flow between
%    the images I1 and I2, but only for the set of features described by
%    the matching points P.
%
%    D = FEATUREPOINTMATCH(I, param1, value1, param2, value2, ...) allows
%    changing the default parameters of the featurePointMatch algorithm.  
%    The available parameters are:
%
%        sigma      - the variance of the gaussians used to filter the
%                     image sequence spatially and temporally
%        filterSize - the size of the temporal and spatial filters
%        patchSize  - the width of the square region, whithin which the
%                     optical flow is assumed to be constant
%        tau        - the minimum disparity value between the patch regions
%                     before the algorithm converges
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: CONSTANTFLOW, PLOTOPTICALFLOW, QUIVER

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 10-December-2013

%% Parameter setting

gaussianSigma = 1.5;
patchSize = 5;
filterSize = 3;
tau = 0.01;

if(nargin > 3 && mod(nargin-3,2) == 0)
    for iArgin = 1:(nargin-3)/2
        if(strcmp(varargin{2*iArgin-1}, 'sigma'))
            gaussianSigma = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'patchSize'))
            patchSize = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'filterSize'))
            filterSize = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'tau'))
            tau = varargin{2*iArgin};
        end
    end
end

N = floor(patchSize / 2.0);

%% Input parsing and variables initialization

% Read the input files
image1 = iread(imageFile1, 'grey', 'double');
image2 = iread(imageFile2, 'grey', 'double');
points = load(pointsFile)';

% Generate the Gaussian filter
gaussianFilter = fspecial('gaussian', filterSize, gaussianSigma);

% Measure the amount of matching points 
nPoint = size(points, 2);

% Initialize the array for storing the calculated displacements
d = zeros(2, nPoint);

%% Main Loop

% For each pair of matching points
for iPoint = 1:nPoint
    
    % Find the location of the current feature in image1 and image2
    c1x = points(1,iPoint);
    c1y = points(2,iPoint);
    c2x = points(3,iPoint);
    c2y = points(4,iPoint);
    
    % Build the patches Q1, Q2 and Q1_image2 (and its larger versions also)
    Q1L = image1(c1x-patchSize:c1x+patchSize, c1y-patchSize:c1y+patchSize);
    Q1L = imfilter(Q1L, gaussianFilter, 'symmetric', 'same', 'conv');
    
    Q2L = image2(c2x-patchSize:c2x+patchSize, c2y-patchSize:c2y+patchSize);
    Q2L = imfilter(Q2L, gaussianFilter, 'symmetric', 'same', 'conv');
    Q2 = Q2L(patchSize+1-N:patchSize+1+N, patchSize+1-N:patchSize+1+N);
    
    Q1L_image2 = image2(c1x-patchSize:c1x+patchSize, c1y-patchSize:c1y+patchSize);
    Q1L_image2 = imfilter(Q1L_image2, gaussianFilter, 'symmetric', 'same', 'conv');    
    
    % Initialize Qprime and the error variable to start iterating
    QprimeL = Q1L_image2;
    error = tau + 1;
    
    % Iterate until convergence is reached
    while(error > tau)
        
        % Calculate the spatial and temporal gradients
        [Gx Gy] = imageGradient(Q1L, 'xy');
        Gt = QprimeL - Q1L;
        
        % Estiamte the velocity of the feature using the constantFlow
        % method
        Ax = reshape(Gx(patchSize+1-N:patchSize+1+N, patchSize+1-N:patchSize+1+N), (2*N+1)^2, 1);
        Ay = reshape(Gy(patchSize+1-N:patchSize+1+N, patchSize+1-N:patchSize+1+N), (2*N+1)^2, 1);
        b = reshape(-Gt(patchSize+1-N:patchSize+1+N, patchSize+1-N:patchSize+1+N), (2*N+1)^2, 1);
        A = [Ax Ay];
        structureTensor = A'*A;
        velocity = structureTensor \ (A'*b);
        d(:,iPoint) = d(:,iPoint) + [velocity(1) ; velocity(2)];
        
        % Generate Qprime by warping the patch Q1L_image2 with the current
        % estimation of 'd'
        [y x] = ndgrid(1:(2*patchSize+1), 1:(2*patchSize+1));
        QprimeL = interp2(x, y, Q1L_image2, x + d(1,iPoint), y + d(2,iPoint));
        Qprime = QprimeL(patchSize+1-N:patchSize+1+N, patchSize+1-N:patchSize+1+N);
        
        % Compare Qprime with Q2
        newError = ssd(Q2, Qprime);
        
        % Update the error variable
        if(abs(newError - error) < tau / 10.0)
            error = 0;
        else
            error = newError;
        end        
    end
end

%% Display the calculated optical flow

figure;
idisp(image1, 'plain');
set(gca,'position',[0 0 1 1],'units','normalized')
hold on;
quiver(points(2,:), points(1,:), d(1,:), d(2,:), 'AutoScaleFactor', 0.5);
