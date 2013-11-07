function [epipoleLeft epipoleRight] = epipolesLocation(F)

% EPIPOLESLOCATION Locate the epipoles of an stereo image set (E. Trucco, page 157)
%    [EL ER] = EPIPOLESLOCATION(F) extracts the location of the epipoles of
%    a stereo image system, based on the Fundamental Matrix of the system.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: EIGHTPOINT, SVD, H2E  

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 02-November-2013

[U ~, V] = svd(F);

epipoleLeft = h2e(U(:,3));
epipoleRight = h2e(V(:,3));