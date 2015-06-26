%NORM	Compute the norm of a quaternion
%
%	N = norm(Q)
%
%	Return a unit-quaternion corresponding to the quaternion Q.
%
%	See also TR2Q

%	Copyright (C) 1993 Peter Corke
function n = norm(q)

	n = norm(double(q));

