%ACCEL	Compute manipulator forward dynamics
%
%	QDD = ACCEL(ROBOT, Q, QD, TORQUE)
%
%	returns a vector of joint accelerations
%	that result from applying the actuator TORQUE to the manipulator ROBOT
%	in state Q and QD.
%
%	Uses the method 1 of Walker and Orin to compute the forward dynamics.
%	This form is useful for simulation of manipulator dynamics, in
%	conjunction with a numerical integration function.
%
%	See also RNE, ROBOT, ODE45.

% MOD HISTORY
% 4/99 add object support

%	Copyright (C) 1999 Peter Corke

function qdd = accel(robot, q, qd, torque)
	q = q(:)';
	qd = qd(:)';

	% compute current manipulator inertia
	M = inertia(robot, q);

	% compute gravity and coriolis torque
	tau = rne(robot, q, qd, zeros(size(q)));	

	qdd = inv(M) * (torque(:) - tau');
