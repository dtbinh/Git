%SUBSREF	subscript reference methods on a LINK object
%
%	LINK(q)	return link xform matrix
%
%	LINK.alpha		return DH parameters
%	LINK.A
%	LINK.theta
%	LINK.D
%	LINK.sigma		return prismatic flag
%	LINK.RP		return 'R' or 'P'
%	LINK.mdh		0 if standard D&H, else 1
%	LINK.offset		joint variable offset
%	LINK.qlim		joint variable limits [min max]
%	LINK.islimit(q)		check if limit is exceeded: -1, 0, +1
%
%	LINK.I		return 3x3 symmetric inertia matrix
%	LINK.m		return link mass
%	LINK.r		return 3x1 link COG vector
%
%	LINK.G		return gear ratio
%	LINK.Jm		return motor inertia
%	LINK.B		return viscous friction
%	LINK.Tc		return viscous friction
%
%	LINK.dh	return legacy DH row
%	LINK.dyn	return legacy DYN row


%	Copyright (C) 1999 Peter. I. Corke
function v = subsref(l, s)
	if s(1).type  == '()'
		if l.mdh == 0,
			v = linktran([l.alpha l.A l.theta l.D l.sigma], ...
				s(1).subs{1}+l.offset);
		else
			v = mlinktran([l.alpha l.A l.theta l.D l.sigma], ...
				s(1).subs{1}+l.offset);
		end
	elseif s(1).type  ~= '.'
		error('only .field supported')
	else

		% NOTE WELL:  the following code can't use getfield() since
		% getfield()  uses this, and Matlab will crash!!

		el = char(s(1).subs);
		switch el,
		case 'alpha',
			v = l.alpha;
		case 'A',
			v = l.A;
		case 'theta',
			v = l.theta;
		case 'D',
			v = l.D;
		case 'offset',
			v = l.offset;
		case 'sigma',
			v = l.sigma;
		case 'RP',
			if l.sigma == 0,
				v = 'R';
			else
				v = 'P';
			end
		case 'mdh',
			v = l.mdh;
		case 'G',
			v = l.G;
		case 'I',
			v = l.I;
		case 'r',
			v = l.r;
		case 'Jm',
			v = l.Jm;
		case 'B',
			v = l.B;
		case 'Tc',
			v = l.Tc;
		case 'qlim',
			v = l.qlim;
		case 'islimit',
			if s(2).type  ~= '()'
				error('expecting argument for islimit method');
			end
			q = s(2).subs{1};
			v = (q > l.qlim(2)) - (q < l.qlim(1));
		case 'm',
			v = l.m;
		case 'dh',
			v = [l.alpha l.A l.theta l.D l.sigma];
		case 'dyn',
			v = [l.alpha l.A l.theta l.D l.sigma ...
			l.m l.r diag(l.I)' l.I(2,1) l.I(2,3) l.I(1,3) l.Jm l.G l.B l.Tc];
		otherwise, disp('Unknown method')
		end
	end


%LINKTRAN	Compute the link transform from kinematic parameters
%
%	LINKTRAN(alpha, an, theta, dn)
%	LINKTRAN(DH, q) is a homogeneous 
%	transformation between link coordinate frames.
%
%	alpha is the link twist angle
%	an is the link length
%	theta is the link rotation angle
%	dn is the link offset
%	sigma is 0 for a revolute joint, non-zero for prismatic
%
%	In the second case, q is substitued for theta or dn according to sigma.
%
%	Based on the standard Denavit and Hartenberg notation.

%	Copright (C) Peter Corke 1993
function t = linktran(a, b, c, d)

	if nargin == 4,
		alpha = a;
		an = b;
		theta = c;
		dn = d;
	else
		if numcols(a) < 4,
			error('too few columns in DH matrix');
		end
		alpha = a(1);
		an = a(2);
		if numcols(a) > 4,
			if a(5) == 0,	% revolute
				theta = b;
				dn = a(4);
			else		% prismatic
				theta = a(3);
				dn = b;
			end
		else
			theta = b;	% assume revolute if sigma not given
			dn = a(4);
		end
	end
	sa = sin(alpha); ca = cos(alpha);
	st = sin(theta); ct = cos(theta);

	t =    [	ct	-st*ca	st*sa	an*ct
			st	ct*ca	-ct*sa	an*st
			0	sa	ca	dn
			0	0	0	1];

%MLINKTRANS	Compute the link transform from kinematic parameters
%
%	MLINKTRANS(alpha, an, theta, dn)
%	MLINKTRANS(DH, q) is a homogeneous 
%	transformation between link coordinate frames.
%
%	alpha is the link twist angle
%	an is the link length
%	theta is the link rotation angle
%	dn is the link offset
%	sigma is 0 for a revolute joint, non-zero for prismatic
%
%	In the second case, q is substitued for theta or dn according to sigma.
%
%	Based on the modified Denavit and Hartenberg notation.

%	Copright (C) Peter Corke 1993
function t = mlinktrans(a, b, c, d)

	if nargin == 4,
		alpha = a;
		an = b;
		theta = c;
		dn = d;
	else
		if numcols(a) < 4,
			error('too few columns in DH matrix');
		end
		alpha = a(1);
		an = a(2);
		if numcols(a) > 4,
			if a(5) == 0,	% revolute
				theta = b;
				dn = a(4);
			else		% prismatic
				theta = a(3);
				dn = b;
			end
		else
			theta = b;	% assume revolute if no sigma given
			dn = a(4);
		end
	end
	sa = sin(alpha); ca = cos(alpha);
	st = sin(theta); ct = cos(theta);

	t =    [	ct	-st	0	an
			st*ca	ct*ca	-sa	-sa*dn
			st*sa	ct*sa	ca	ca*dn
			0	0	0	1];
