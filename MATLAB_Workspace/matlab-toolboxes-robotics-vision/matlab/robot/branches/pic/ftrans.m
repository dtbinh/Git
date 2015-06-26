%FTRANS	transform force/moment
%
%	Ft = FTRANS(T, F)
%
%  Transforms a force/moment F in the base frame to Ft in the frame T.
%  F and Ft are 6-vectors of the form [Fx Fy Fz Mx My Mz]

% Copyright (c) 1999 Peter Corke

function Ft = ftrans(T, F)

	f = F(1:3); m = F(4:6);
	k = cross(f, transl(T) ) + m;

	mt = rot(T)' * k;
	ft = rot(T)' * F(1:3);

	Ft = [ft; mt];
