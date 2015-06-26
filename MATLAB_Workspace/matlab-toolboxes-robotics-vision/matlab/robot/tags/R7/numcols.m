%NUMCOLS Return number of columns in matrix
%
%	NC = NUMCOLS(M)
%
% Return the number of columns in the matrix M.

% Copyright (C) 1993-2002, by Peter I. Corke

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $

function c = numcols(m)
	[x,c] = size(m);
