%TR2DIFF	Convert a transform difference to differential representation
%
%	TR2DIFF(T)
%
%	TR2DIFF(T1, T2)
%
%	First form converts a homogeneous transform representing an
%	infinitessimal motion to a 6-element differential representation.
%	Such a homogeneous transform has a rotational submatrix that is,
%	approximately, skew symmetric.
%
%	Second form returns the 6-element differential motion required to move
%	from T1 to T2 in base coordinates.
%
%	See also DIFF2TR, DIFF, IKINE

%	Copyright (C) Peter Corke 1993

% MOD.HISTORY
%	1/95	take mean of both values in the skew-symmetric matrix
%	2/95	add two argument version as part of ikine() revamp

function d = tr2diff(t1, t2)
	if nargin == 1,
		d = [	t1(1:3,4);
			0.5*[t1(3,2)-t1(2,3); t1(1,3)-t1(3,1); t1(2,1)-t1(1,2)]];
	else
		d = [	t2(1:3,4)-t1(1:3,4);
			0.5*(	cross(t1(1:3,1), t2(1:3,1)) + ...
				cross(t1(1:3,2), t2(1:3,2)) + ...
				cross(t1(1:3,3), t2(1:3,3)) ...
			)];
	end

