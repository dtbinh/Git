%UNIT	Unitize a vector
%
%	UNIT(V) returns a unit vector aligned with V.

%	Copright (C) Peter Corke 1990
function qu = unit(q)
	qu = q / norm(q);
