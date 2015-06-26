%DOUBLE	convert a quaternion object to a 4-element vector

%	Copright (C) Peter Corke 1999
function v = double(q)

	v = [q.s q.v];
