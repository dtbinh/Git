%INV	Invert a unit-quaternion
%
%	QI = inv(Q)
%
%	Return the inverse of the unit-quaternion Q.
%

%	Copyright (C) 1993 Peter Corke
function qi = inv(q)

	qi = quaternion([q.s -q.v] / norm(q)^2);
