%ROTX Rotation about X axis
%
%	TR = ROTX(theta)
%
% Returns a homogeneous transformation representing a rotation of theta 
% about the X axis.
%
% See also: ROTY, ROTZ, ROTVEC.

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
% Copyright (C) 1993-2002, by Peter I. Corke

function r = rotx(t)
	ct = cos(t);
	st = sin(t);
	r =    [1	0	0	0
		0	ct	-st	0
		0	st	ct	0
		0	0	0	1];
