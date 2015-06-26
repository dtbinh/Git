%TRNORM	Normalize a homogeneous transformation.
%
%	TN = TRNORM(T) 
%
%	Returns a normalized homogeneous tranformation matrix in which the rotation
%	submatrix is a proper orthogonal matrix.
%	The O and V vectors are normalized and the normal vector is formed from
%	O x A.
%
%	Finite word length arithmetic can cause transforms to become `unnormalized'.
%
%	See also OA2TR

%	Copyright (C) 1993 Peter Corke
function r = trnorm(t)
	n = cross(t(1:3,2), t(1:3,3));	% N = O x A
	r = [unit(n) unit(t(1:3,2)) unit(t(1:3,3)) t(1:3,4); 0 0 0 1];
