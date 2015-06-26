%ROTZ Rotation about Z axis
%
%	TR = ROTZ(theta)
%
% Returns a homogeneous transformation representing a rotation of theta 
% about the Z axis.
%
% See also: ROTX, ROTY, ROTVEC.

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
% Copyright (C) 1993-2002, by Peter I. Corke

function r = rotz(t)
	ct = cos(t);
	st = sin(t);
	r =    [ct	-st	0	0
		st	ct	0	0
		0	0	1	0
		0	0	0	1];
