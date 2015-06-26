%CHAR Create string representation of quaternion object

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
%
% Copyright (C) 1999-2002, by Peter I. Corke

function s = char(q)

	s = [num2str(q.s), ' <' num2str(q.v(1)) ', ' num2str(q.v(2)) ', '   num2str(q.v(3)) '>'];
