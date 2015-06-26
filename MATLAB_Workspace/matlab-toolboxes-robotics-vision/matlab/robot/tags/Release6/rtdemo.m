echo off
%RTDEMO		Robot toolbox demonstrations
%
%

%	Copyright (C) Peter Corke 1993
clear all
puma560
while 1,
	selection = menu('Robot Toolbox demonstrations', ...
		'Transformations', ...
		'Trajectory', ...
		'Forward kinematics', ...
		'Animation', ...
		'Inverse kinematics', ...
		'Jacobians', ...
		'Inverse dynamics', ...
		'Forward dynamics', ...
		'Exit');

	switch selection,
	case 1,
		rttrdemo
	case 2,
		rttgdemo
	case 3,
		rtfkdemo
	case 4,
		rtandemo
	case 5,
		rtikdemo
	case 6,
		rtjademo
	case 7,
		rtidemo
	case 8,
		rtfddemo
		% chaotic 2 link
	case 9,
		break;
	end
end
