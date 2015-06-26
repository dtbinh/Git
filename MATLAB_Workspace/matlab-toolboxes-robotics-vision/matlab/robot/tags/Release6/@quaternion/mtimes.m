%MTIMES	multiply two quaternion objects

%	Copright (C) Peter Corke 1999
function qp = mtimes(q1, q2)

	if isa(q2, 'quaternion')
	%QQMUL	Multiply unit-quaternion by unit-quaternion
	%
	%	QQ = qqmul(Q1, Q2)
	%
	%	Return a product of unit-quaternions.
	%
	%	See also TR2Q

	%	Copyright (C) 1993 Peter Corke

		% decompose into scalar and vector components
		s1 = q1.s;	v1 = q1.v;
		s2 = q2.s;	v2 = q2.v;

		% form the product
		qp = quaternion([s1*s2-v1*v2' s1*v2+s2*v1+cross(v1,v2)]);

	elseif all(size(q2) == [3 1])

	%QVMUL	Multiply vector by unit-quaternion
	%
	%	VT = qvmul(Q, V)
	%
	%	Rotate the vector V by the unit-quaternion Q.
	%
	%	See also QQMUL, QINV

	%	Copyright (C) 1993 Peter Corke

		qp = q1 * quaternion([0 q2']);
		qp = qp.v;
	end
