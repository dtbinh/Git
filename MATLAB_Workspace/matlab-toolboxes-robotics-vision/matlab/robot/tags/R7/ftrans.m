%FTRANS Transform force/moment
%
%	FT = FTRANS(T, F)
%
% Transforms a force/moment F in the base frame to FT in the frame T.
% F and FT are 6-vectors of the form [Fx Fy Fz Mx My Mz]
%
% SEE ALSO: DIFF2TR

% $Log: not supported by cvs2svn $
% Revision 1.2  2002/04/01 11:47:13  pic
% General cleanup of code: help comments, see also, copyright, remnant dh/dyn
% references, clarification of functions.
%
% $Revision: 1.3 $
% Copyright (C) 1999-2002, by Peter I. Corke

function Ft = ftrans(T, F)

	f = F(1:3); m = F(4:6);
	k = cross(f, transl(T) ) + m;

	mt = rot(T)' * k;
	ft = rot(T)' * F(1:3);

	Ft = [ft; mt];
