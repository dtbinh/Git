%DOUBLE Convert a quaternion object to a 4-element vector

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
%
% Copyright (C) 1999-2002, by Peter I. Corke

function v = double(q)

	v = [q.s q.v];
