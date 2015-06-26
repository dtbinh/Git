%GRAVLOAD	Compute the gravity loading on manipulator joints
%
%	GRAVLOAD(DYN, Q) is the joint gravity loading for a manipulator whose
%	dynamics and kinematics are described by DYN, and Q is the joint state.
%
%	If Q is a row vector, GRAVLOAD(DYN, Q) is a row vector of joint torques.
%	If Q is a matrix, each row is interpretted as a joint state vector, and
%	GRAVLOAD(DYN,Q) is a matrix each row being the corresponding joint 
%	torques.
%
%	GRAVLOAD(DYN,Q,GRAV) allows an arbitrary gravity vector to override
%	the default of [0; 0; 9.81]
%
%	See also DYN, RNE, ITORQUE, CORIOLIS.

%	Copright (C) Peter Corke 1993
function tg = gravload(dyn, q, grav)
	if numcols(q) ~= numrows(dyn),
		error('')
	end
	if nargin == 2,
		tg = rne(dyn, q, zeros(size(q)), zeros(size(q)));
	elseif nargin == 3,
		tg = rne(dyn, q, zeros(size(q)), zeros(size(q)), grav);
	end
	
