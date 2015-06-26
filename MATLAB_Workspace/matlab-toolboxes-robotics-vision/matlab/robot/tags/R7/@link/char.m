%CHAR Create string representation of LINK object

% $Log: not supported by cvs2svn $
% $Revision: 1.3 $
% Copyright (C) 1999-2002, by Peter I. Corke

function s = char(l)

	jtype = 'RP';

	if l.mdh == 0,
		conv = 'std';
	else
		conv = 'mod';
	end

	s = sprintf('%f\t%f\t%f\t%f\t%c\t(%s)', l.alpha, l.A, l.theta, l.D, ...
		jtype((l.sigma==1) + 1), ...
		conv);
