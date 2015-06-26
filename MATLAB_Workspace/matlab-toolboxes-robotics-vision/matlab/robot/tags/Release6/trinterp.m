%TRINTERP	Interpolate homogeneous transformations
%
%	T = TRINTERP(T0, T1, R)
%
%	Returns a homogeneous transform interpolation between T0 and T1 as
%	R varies from 0 to 1.  Rotation is interpolated using quaternion
%	spherical linear interpolation.
%
%	See also CTRAJ, DRIVEPAR, QINTERP

%	Copyright (C) 1993 Peter Corke

% MOD.HISTORY
%	12/94	must have T0 as well as DP
%	3/96	fixed bug: sin/cos(dp(4)) should be of dp(6)

function t = trinterp(T0, T1, r)

	q0 = quaternion(T0);
	q1 = quaternion(T1);

	p0 = transl(T0);
	p1 = transl(T1);

	qr = qinterp(q0, q1, r);
	pr = p0*(1-r) + r*p1;

	t = [qr.r pr; 0 0 0 1];
