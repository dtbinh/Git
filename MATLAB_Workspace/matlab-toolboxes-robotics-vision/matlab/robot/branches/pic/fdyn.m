%FDYN	Integrate forward dynamics
%
%	[T Q QD] = FDYN(ROBOT, T0, T1)
%	[T Q QD] = FDYN(ROBOT, T0, T1, TORQFUN)
%	[T Q QD] = FDYN(ROBOT, T0, T1, TORQFUN, Q0, QD0)
%
%	Integrates the dynamics of manipulator ROBOT dynamics over the time 
%	interval and returns vectors of joint position and velocity.
%	ROBOT is a robot object and describes the manipulator dynamics and 
%	kinematics, and Q is an n element vector of joint state.
%
%	A control torque may be specified by a user specified function
%
%		TAU = TORQFUN(T, X)
%
%	where X is a 2n-element column vector [Q; QD], and T is the current 
%	time.	If TORQFUN is not specified then zero torque is applied to 
%	the manipulator.
%
%	See also ACCEL, RNE, ROBOT, ODE45.

%	Copyright (C) 1993 Peter Corke
% MOD HISTORY
% 4/99 add object support

%	Copyright (C) 1999 Peter Corke

function [t, q, qd] = fdyn(robot, t0, t1, torqfun, q0, qd0)

	% check the Matlab version, since ode45 syntax has changed
	v = ver;
	if str2num(v(1).Version)<6,
		error('fdyn now requires Matlab version >= 6');
	end

	n = robot.n;
	if nargin == 3,
		torqfun = 0;
		x0 = zeros(2*n,1);
	elseif nargin == 4,
		x0 = zeros(2*n, 1);
	elseif nargin == 6,
		x0 = [q0(:); qd0(:)];
	end
		
	[t,y] = ode45(@fdyn2, [t0 t1], x0, [], robot, torqfun);
	q = y(:,1:n);
	qd = y(:,n+1:2*n);



% private function called by fdyn()
%
% MOD HISTORY
% 4/99 add object support

%	Copyright (C) 1999 Peter Corke
function xd = fdyn2(t, x, robot, torqfun)

	n = robot.n;

	q = x(1:n);
	qd = x(n+1:2*n);
	if isstr(torqfun)
		tau = feval(torqfun, t, q, qd);
	else
		tau = zeros(n,1);
	end
	
	qdd = accel(robot, x(1:n,1), x(n+1:2*n,1), tau);
	xd = [x(n+1:2*n,1); qdd];
