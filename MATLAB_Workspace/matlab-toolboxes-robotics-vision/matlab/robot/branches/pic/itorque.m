%ITORQUE	Compute the manipulator inertia torque
%
%	ITORQUE(DYN, Q, QDD) for an n-axis manipulator returns the n element
%	inertia torque vector at the specified pose and acceleration, that is,
%		INERTIA(Q)*QDD
%	DYN describes the manipulator dynamics and kinematics.
%	If Q and QDD are row vectors, ITORQUE(DYN,Q,QDD) is a row vector 
%	of joint torques.
%	If Q and QDD are matrices, each row is interpretted as a joint state 
%	vector, and ITORQUE(DYN,Q,QDD) is a matrix each row being the 
%	corresponding joint torques.
%
%	See also DYN, RNE, CORIOLIS, INERTIA, GRAVLOAD.


%	Copright (C) Peter Corke 1993
function it = itorque(dyn, q, qdd)
	it = rne(dyn, q, zeros(size(q)), qdd, [0;0;0]);
