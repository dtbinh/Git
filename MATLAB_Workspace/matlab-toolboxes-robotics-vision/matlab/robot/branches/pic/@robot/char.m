function s = char(r)
%
% render a string representation of the robot parameters
%       Copyright (C) Peter Corke 1999


	% build a configuration string
	rp = [];
	for i = 1:r.n,
		rp = [rp r.link{i}.RP];
	end

	s = sprintf('%s (%d axis, %s)', r.name, r.n, rp);

	if ~isempty(r.manuf)
		s = strcat(s, [' [' r.manuf ']']);
	end
	if ~isempty(r.comment)
		s = strcat(s, [' <' r.comment '>']);
	end
	s = strcat(s, sprintf('\n\t\tgrav = [%.2f %.2f %.2f]\n', r.gravity));
	if getfield(r, 'mdh') == 0,
		s = strcat(s, sprintf('\t\tstandard D&H parameters\n'));
	else
		s = strcat(s, sprintf('\t\tmodified D&H parameters\n'));
	end

	s = strcat(s, sprintf('\n  alpha\t\t  A\t\t  theta\t\t  D\t\tR/P\n'));
	for i = 1:r.n,
		s = strcat(s, sprintf('%s\n', char(r.link{i})));
	end
