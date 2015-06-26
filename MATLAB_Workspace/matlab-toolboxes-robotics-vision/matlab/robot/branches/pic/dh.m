%DH	Matrix representation of manipulator kinematics
%
%	Many robot toolbox functions take a DH matrix which describes the
%	kinematics of a manipulator in a general way.
%
%	For an n-axis manipulator, DH is an nx4 or nx5 matrix, whose rows 
%	comprise
%	
%	1	alpha	link twist angle
%	2	A	link length
%	3	theta	link rotation angle
%	4	D	link offset distance
%	5	sigma	joint type, 0 for revolute, non-zero for prismatic
%
%	If the last column is not given, most toolbox functions assume that
%	the manipulator is all-revolute.
%
%	The first 5 columns of a DYN matrix contain the kinematic parameters
%	and maybe used anywhere that a DH kinematic matrix is required -- the
%	dynamic data is ignored.
%
%	See also DYN.

% MOD.HISTORY
%	1/95	reverse labels on A & D%	Copright (C) Peter Corke 1993
