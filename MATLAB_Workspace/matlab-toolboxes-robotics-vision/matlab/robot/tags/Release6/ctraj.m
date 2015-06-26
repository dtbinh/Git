%CTRAJ	Compute a Cartesian trajectory between two points
%
%	TC = CTRAJ(T0, T1, N)
%	TC = CTRAJ(T0, T1, R)
%
%	Returns a Cartesian trajectory TC from point T0 to T1.  The number
%	of points is N or the length of the given path distance vector R.
%
% 	In the first case the points are equally spaced between T0 and T1.
%	In the second case R gives the distance along the path, and the 
%	elements of R must be in the range [0 1].
%
%	Each trajectory is a 4x4xn matrix, with the last subscript being the
%	point index.
%

%	Copyright (C) Peter Corke 1993

% MOD. HISTORY
%	12/94	track changes to trinterp()
% 4/99 add object support
%	6/99	init tt to zeros rather than [], problem with cat() v 5.3

%	Copyright (C) 1999 Peter Corke

function tt = ctraj(t0, t1, n)
	if length(n) == 1,
		i = 1:n;
		r = (i-1)/(n-1);
	else
		r = n(:)';
		n = length(r);
	end

	if any(r> 1) | any(r<0),
		error('path position values (R) must 0<=R<=1)')
	end
	tt = zeros(4,4,0);

	for R=r,
		tt = cat(3, tt, trinterp(t0, t1, R));
	end

	
