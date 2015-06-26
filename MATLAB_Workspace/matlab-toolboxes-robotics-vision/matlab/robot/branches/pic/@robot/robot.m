%ROBOT	robot object constructor
%
%	ROBOT
%	ROBOT(robot)		create a copy of an existing ROBOT object
%	ROBOT(LINK, ...)	create from a cell array of LINK objects
%	ROBOT(DH, ...)		create from legacy DYN matrix
%	ROBOT(DYN, ...)		create from legacy DYN matrix
%
%	optional trailing arguments are:
%		Name			robot type or name
%		Manufacturer		who built it
%		Comment			general comment
%
%  If the legacy matrix forms are used the default name is the workspace
% variable that held the data.


%	Copyright (C) Peter Corke 1999
function r = robot(L, name, manuf, comment)

	if nargin == 0
		r.name = 'noname';
		r.manuf = '';
		r.comment = '';
		r.link = {};
		r.n = 0;
		r.mdh = 0;
		r.gravity = [0; 0; 9.81];
		r.base = eye(4,4);
		r.tool = eye(4,4);
		r.handle = [];	% graphics handles
		r.q = [];	% current joint angles
		r.plotopt = {};
		r.lineopt = {'Color', 'black', 'Linewidth', 4};
		r.shadowopt = {'Color', 'black', 'Linewidth', 1};
		r = class(r, 'robot');
	elseif isa(L, 'robot')
		r = L;
	else
		if nargin > 1,
			r.name = name;
		else
			r.name = 'noname';
		end
		if nargin > 2,
			r.manuf = manuf;
		else
			r.manuf = '';
		end
		if nargin > 3,
			r.comment = comment;
		else
			r.comment = '';
		end

		if isa(L, 'double')
			% legacy matrix
			dh_dyn = L;
			clear L
			for j=1:numrows(dh_dyn)
				L{j} = link(dh_dyn(j,:));
			end
			% get name of variable
			r.name = inputname(1);
			r.link = L;
		elseif iscell(L) & isa(L{1}, 'link')

			r.link = L;
		else
			error('unknown type passed to robot');
		end
		r.n = length(L);

		% set the robot object mdh status flag
		mdh = [];
		for j = 1:length(L)
			mdh = [mdh L{j}.mdh];
		end
		if all(mdh == 0)
			r.mdh = mdh(1);
		elseif all (mdh == 1)
			r.mdh = mdh(1);
		else
			error('robot has mixed D&H link conventions');
		end

		% fill in default base and gravity direction
		r.gravity = [0; 0; 9.81];
		r.base = eye(4,4);
		r.tool = eye(4,4);
		r.handle = [];
		r.q = [];
		r.plotopt = {};
		r.lineopt = {'Color', 'black', 'Linewidth', 4};
		r.shadowopt = {'Color', 'black', 'Linewidth', 1};

		r = class(r, 'robot');
	end
