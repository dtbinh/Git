%ISHOMOG Test if argument is a homogeneous transformation
%
%	H = ISHOMOG(TR)
%
%  Returns true (1) if the argument tr is of dimension 4x4.

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
% Copyright (C) 2002, by Peter I. Corke

function h = ishomog(tr)
	if ndims(tr) == 2,
		h =  all(size(tr) == [4 4]);
	else
		h = 0;
	end
