function range = range2(M)

% RANGE2 Sample range of 2D data
%    Y = RANGE2(M) returns the range of all values of M. It is a simple
%    extension of the function range, for bidimensional data.
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: RANGE, MIN, MAX

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 30-October-2013

range = max(max(M)) - min(min(M));