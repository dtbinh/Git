%QINTERP	Interpolate rotations expressed by quaternion objects
%
%	QI = qinterp(Q1, Q2, R)
%
%	Return a unit-quaternion that interpolates between Q1 and Q2 as R moves
%	from 0 to 1.  This is a spherical linear interpolation (slerp) that can
%	be interpretted as interpolation along a great circle arc on a sphere.
%
%	If r is a vector, QI, is a cell array of quaternions.
%
%	See also TR2Q

% MOD HISTORY
% 2/99	convert to use of objects

%	Copright (C) Peter Corke 1999
function q = qinterp(Q1, Q2, r)


	q1 = double(Q1);
	q2 = double(Q2);

	if (r<0) | (r>1),
		error('R out of range');
	end

	theta = acos(q1*q2');
	q = {};
	count = 1;

	if length(r) == 1,
		if theta == 0,
			q = Q1;
		else
			q = quaternion( (sin((1-r)*theta) * q1 + sin(r*theta) * q2) / sin(theta) );
		end
	else
		for R=r(:)',
			if theta == 0,
				qq = Q1;
			else
				qq = quaternion( (sin((1-R)*theta) * q1 + sin(R*theta) * q2) / sin(theta) );
			end
			q{count} = qq;
			count = count + 1;
		end
	end
