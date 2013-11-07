function F = eightPoint(PL, PR)

% EIGHTPOINT Estimate the Fundamental Matrix (E. Trucco, page 156)
%    F = EIGHTPOINT(PL, PR) estimates the Fundamental Matrix of a pair of
%    stereo images, using the matching points PL and PR.
%
%
%    Other m-files required: normalizePoints.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: FINDANDPLOTEPIPOLARLINES, NORMALIZEPOINTS, SVD, RESHAPE, E2H  

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 02-November-2013

%% Convert the points to homogeneous coordinates
nPoint = size(PR, 1);
PL = e2h(PL')';
PR = e2h(PR')';

%% Normalize points
[PLnorm TL] = normalizePoints(PL);
[PRnorm TR] = normalizePoints(PR);

%% Build the linear equation system matrix
A = zeros(nPoint, 9);
for iPoint = 1:nPoint
    for i = 1:3
        for j = 1:3
            A(iPoint, 3*(i-1)+j) = PRnorm(iPoint,i)*PLnorm(iPoint,j);
        end
    end
end

%% Estimate the Fundamental Matrix using the SVD of the system matrix
[~, ~, V] = svd(A);
F = reshape(V(:,9),3,3)';

%% Adjust the rank of F to 2
[U,D,V] = svd(F);
D(3,3) = 0;
F = U*D*V';

%% Denormalize F
F = TR'*F*TL;
