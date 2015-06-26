%UNIT Unitize a quaternion
%
%	QU = UNIT(Q)
%
% Returns a unit quaternion.

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
%
% Copyright (C) 1999-2002, by Peter I. Corke

function qu = unit(q)
	qu = q / norm(q);
