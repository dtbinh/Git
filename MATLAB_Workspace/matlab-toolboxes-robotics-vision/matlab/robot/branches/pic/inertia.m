%INERTIA	Compute the manipulator inertia matrix
%
%	INERTIA(DYN, Q) for an n-axis manipulator returns the nxn symmetric 
%	inertia matrix which relates joint torque to joint acceleration.
%	DYN describes the manipulator dynamics and kinematics, and Q is
%	an n element vector of joint state.
%
%	See also DYN, RNE, ITORQUE, CORIOLIS, GRAVLOAD.


%	Copright (C) Peter Corke 1993
% MOD HISTORY
% 4/99 add objects
%	6/99	init M to zeros rather than [], problem with cat() v 5.3

function M = inertia(robot, q)
	n = robot.n;

	if length(q) == robot.n,
		q = q(:)';
	end

	M = zeros(n,n,0);
	for Q = q',
		m = rne(robot, ones(n,1)*Q', zeros(n,n), eye(n), [0;0;0]);
		M = cat(3, M, m);
	end
