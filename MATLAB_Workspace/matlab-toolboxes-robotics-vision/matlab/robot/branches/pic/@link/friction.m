%FRICTION	compute friction torque on the LINK object
%
%	TAU = FRICTION(LINK, QD)
%
%	Return the friction torque on the link moving at speed QD.  Depending
%	on fields in the LINK object viscous and/or Coulomb friction
%	are computed.
%

% MOD HISTORY
% 3/99	modify to use on a LINK object

%	Copyright (C) 1999 Peter. I. Corke

function  tau = friction(l, qd)
	tau = 0.0;

	qd = qd(:);
	tau = l.B * qd;

	tau = tau + (qd > 0) * l.Tc(1) + (qd < 0) * l.Tc(2);
