%LINK create a new LINK object
%
% A LINK object holds all information related to a robot link such as
% kinematics of the joint, rigid-body inertial parameters, motor and
% transmission parameters.
%
%	LINK
%	LINK(link)
%
%	Create a default link, or a clone of the passed link.
%
%	A = LINK(q)
%
%	Compute the link transform matrix for the link, given the joint
%	variable q.
%
%	LINK([alpha A theta D sigma])
%	LINK(DH_ROW)	create from row of legacy DH matrix
%	LINK(DYN_ROW)	create from row of legacy DYN matrix
%
% Any of the last 3 forms can have an optional flag argument which is 0
% for standard D&H parameters and 1 for modified D&H parameters.
% Handling the different kinematic conventions is now hidden within the LINK
% object.
%
% Conceivably all sorts of stuff could live in the LINK object such as
% graphical models of links and so on.

% MOD HISTORY
% 3/99	modify to use on a LINK object
% 6/99	fix the number of fields inthe object, v5.3 doesn't let me change them
%	mod by  Francisco Javier Blanco Rodriguez <jblanco@abedul.usal.es>

%	Copyright (C) 1999 Peter. I. Corke

function l = link(dh, mdh)

	% link([alpha A theta D sigma])

	if nargin == 0,
		l.alpha = 0;
		l.A = 0;
		l.theta = 0;
		l.D = 0;
		l.sigma = 0;
		l.mdh = 0;
		l.offset = 0;
		
		% it's a legacy DYN matrix
		l.m = [];
		l.r = [];
		v = [];
		l.I = [];
		l.Jm = [];
		l.G = [];
		l.B = [];
		l.Tc = [];
		l.qlim = [];

		l = class(l, 'link');

	elseif isa(dh, 'link')
		l = dh;
	elseif length(dh) <= 6,
		% legacy DH matrix

		l.alpha = dh(1);
		l.A = dh(2);
		l.theta = dh(3);
		l.D = dh(4);
		l.sigma = 0;
		if length(dh) >= 5,
			l.sigma = dh(5);
		end
		if nargin > 1
			l.mdh = mdh;
		else
			l.mdh = 0;	% default to standard D&H
		end
		l.offset = 0;
		if length(dh) >= 6,
			l.offset = dh(6);
		end

		% we know nothing about the dynamics
		l.m = [];
		l.r = [];
		v = [];
		l.I = [];
		l.Jm = [];
		l.G = [];
		l.B = [];
		l.Tc = [];
		l.qlim = [];

		l = class(l, 'link');
	else
		% legacy DYN matrix

		l.alpha = dh(1);
		l.A = dh(2);
		l.theta = dh(3);
		l.D = dh(4);
		if length(dh) == 4,
			l.sigma = 0;
		else
			l.sigma = dh(5);
		end
		if nargin > 1
			l.mdh = mdh;
		else
			l.mdh = 0;	% default to standard D&H
		end
		l.offset = 0;
		
		% it's a legacy DYN matrix
		l.m = dh(6);
		l.r = dh(7:9)';		% a column vector
		v = dh(10:15);
		l.I = [	v(1) v(4) v(6)
			v(4) v(2) v(5)
			v(6) v(5) v(3)];
		if length(dh) > 15,
			l.Jm = dh(16);
		end
		if length(dh) > 16,
			l.G = dh(17);
		else
			l.G = 1;
		end
		if length(dh) > 17,
			l.B = dh(18);
		else
			l.B = 0.0;
		end
		if length(dh) > 18,
			l.Tc = dh(19:20);
		else
			l.Tc = [0 0];
		end
		l.qlim = [];
		l = class(l, 'link');
	end
