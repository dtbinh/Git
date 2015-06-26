%TR2ROT	return rotational submatrix of a homogeneous transformation
%
%	R = TR2ROT(T)
%
% where T is a 4x4 homogeneous transformation and R is a 3x3 orthonormal
% rotation matrix.
%
% SEE ALSO: rot2tr

% Copyright (c) 1999 Peter Corke
function R = tr2rot(T)

	if ~ishomog(T)
		error('input must be a homogeneous transform');
	end

	R = T(1:3,1:3);
