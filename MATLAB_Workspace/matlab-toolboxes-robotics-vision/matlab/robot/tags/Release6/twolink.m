%TWOLINK	Load kinematic and dynamic data for a simple 2-link mechanism
%
%	Defines the matrix 'twolink' which describes the kinematic and dynamic
%	characterstics of a simple planar 2-link mechanism.
%
%	Example based on Fig 3-6 of Spong and Vidyasagar.  It is a planar mechanism operating
%	in the vertical plane, ie. it is affected by gravity.
%
%	Assume unit length links with all mass (unity) concentrated at the joints.
%
%	See also DH, DYN, PUMA560, STANFORD.
%

%	Copright (C) Peter Corke 2000

twolink_dh = [
% alpha	A	theta	D	sigma	m	rx	ry	rz	Ixx	Iyy	Izz	Ixy	Iyz	Ixz	Jm	G
  0     1         0     0         0     1       1       0       0       0       0       0       0       0       0        0      1
  0     1         0     0         0     1       1       0       0       0       0       0       0       0       0        0      1
];

tl = robot(twolink_dh);
tl.name = 'Simple two link';
qz = [0 0];
