%INV Invert a unit-quaternion
%
%	QI = inv(Q)
%
% Return the inverse of the unit-quaternion Q.
%

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
%
% Copyright (C) 1999-2002, by Peter I. Corke

function qi = inv(q)

	qi = quaternion([q.s -q.v]);
