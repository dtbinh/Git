%MRDIVIDE	compute quotient of two quaternion objects

%	Copright (C) Peter Corke 1999
function qq = mrdivide(q1, q2)

	if isa(q2, 'quaternion'),
		% qq = q1 / q2
		%    = q1 * qinv(q2)

		qq = q1 * inv(q2);
	elseif isa(q2, 'double'),
		qq = quaternion( double(q1) / q2 );
	end
