%UNIT Unitize a vector
%
%	VN = UNIT(V)
%
% Returns a unit vector aligned with V.

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
% Copyright (C) 1990-2002, by Peter I. Corke

function u = unit(v)
	u = v / norm(v,'fro');
