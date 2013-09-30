function repeatFilter = repeatedMeanFilter(N)

% REPEATEDMEANFILTER Generates e repeated averaging mask
%    repeatF = repeatedMeanFilter(N) is a mask obtained by convolving the
%    averaging (mean filter) mask to itself N times. repeatF is a square
%    matrix of size 3 + 2*N.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: GAUSSIANANDRA

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

meanFilter = ones(3) / 9.0;
repeatFilter = meanFilter;

for i = 1:N
    repeatFilter = iconv(repeatFilter, meanFilter, 'full');
end