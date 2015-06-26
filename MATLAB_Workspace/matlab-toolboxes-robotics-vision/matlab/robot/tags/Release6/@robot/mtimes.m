%	robot objects can be multiplied r1*r2 which is mechanically equivalent
%	to mounting robot r2 on the end of robot r1.
%
%	Copyright (C) Peter Corke 1999
function r2 = mtimes(r, l)

	if ~isa(r, 'robot')
		error('left arg must be a robot')
	end
	if isa(l, 'robot')
		r2 = robot(r);
		r2.link = [r2.link l.link];
		r2.n = length(r2.link);
	elseif isa(l, 'link')
	end
