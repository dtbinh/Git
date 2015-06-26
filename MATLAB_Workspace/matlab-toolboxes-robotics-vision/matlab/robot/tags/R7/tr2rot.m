%TR2ROT Return rotational submatrix of a homogeneous transformation
%
%	R = TR2ROT(T)
%
% Return R the 3x3 orthonormal rotation matrix from the homogeneous 
% transformation T.
%
% SEE ALSO: ROT2TR

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
% Copyright (C) 1999-2002, by Peter I. Corke

function R = tr2rot(T)

	if ~ishomog(T)
		error('input must be a homogeneous transform');
	end

	R = T(1:3,1:3);
