%CORIOLIS	Compute the manipulator coriolis matrix
%
%	CORIOLIS(ROBOT, Q, QD) for an n-axis manipulator returns the n element
%	coriolis torque vector at the specified pose and velocity.
%	ROBOT is a robot object and describes the manipulator dynamics and 
%	kinematics.
%
%	If Q and QD are row vectors, CORIOLIS(DYN,Q,QD) is a row vector 
%	of joint torques.
%	If Q and QD are matrices, each row is interpretted as a joint state 
%	vector, and CORIOLIS(DYN,Q,QD) is a matrix each row being the 
%	corresponding joint %	torques.
%
%	See also ROBOT, RNE, ITORQUE, GRAVLOAD.


%	Copright (C) Peter Corke 1993
% MOD HISTORY
% 4/99 add object support

%	Copyright (C) 1999 Peter Corke
function c = coriolis(robot, q, qd)
	c = rne(robot, q, qd, zeros(size(q)), [0;0;0]);
