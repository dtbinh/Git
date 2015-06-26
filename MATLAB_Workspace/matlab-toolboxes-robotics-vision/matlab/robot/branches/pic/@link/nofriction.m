%NOFRICTION	return link object with zero friction 
%
%	LINK = NOFRICTION(LINK)
%
%

% MOD HISTORY

%	Copyright (C) 1999 Peter. I. Corke

function  l2 = nofriction(l)

	l2 = link(l);

	l2.B = 0;
	l2.Tc = [0 0];
