%CHAR	create string representation of quaternion object

%	Copright (C) Peter Corke 1999
function s = char(q)

	s = [num2str(q.s), ' <' num2str(q.v(1)) ', ' num2str(q.v(2)) ', '   num2str(q.v(3)) '>'];
