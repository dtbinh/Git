%NORM Compute the norm of a quaternion
%
%	QN = norm(Q)
%
% Return a unit-quaternion corresponding to the quaternion Q.
%

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
%
% Copyright (C) 1993-2002, by Peter I. Corke

function n = norm(q)

	n = norm(double(q));

