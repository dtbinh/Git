%OA2TR
%
%	OA2TR(O, A) returns a homogeneous tranformation for the specified
%	orientation and approach vectors.
%
%	See also RPY2TR, EUL2TR

%	Copyright (C) 1993 Peter Corke
function r = oa2tr(o, a)
	n = cross(o, a);
	r = [unit(n(:)) unit(o(:)) unit(a(:)) zeros(3,1); 0 0 0 1];
