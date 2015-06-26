%CINERTIA	Compute the Cartesian (operational space) manipulator inertia matrix
%
%	CINERTIA(ROBOT, Q) for the n-axis manipulator ROBOT returns the nxn 
%	inertia matrix which relates Cartesian force/torque to Cartesian
%	acceleration.
%	ROBOT is a robot object and describes the manipulator dynamics and 
%	kinematics, and Q is an n element vector of joint state.
%
%	See also INERTIA, ROBOT, RNE.

%	Copyright (C) 1993 Peter Corke
% MOD HISTORY
% 4/99 add object support

%	Copyright (C) 1999 Peter Corke

function Mx = cinertia(robot, q)
	J = jacob0(robot, q);
	Ji = inv(J);
	M = inertia(robot, q);
	Mx = Ji' * M * Ji;
