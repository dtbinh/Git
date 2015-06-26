%NUMROWS Return number of rows in matrix
%
%	NR = NUMROWS(M)
%
% Return the number of rows in the matrix M.


% Copyright (C) 1993-2002, by Peter I. Corke
% $Log: not supported by cvs2svn $
% $Revision: 1.2 $

function r = numrows(m)

	[r,x] = size(m);
