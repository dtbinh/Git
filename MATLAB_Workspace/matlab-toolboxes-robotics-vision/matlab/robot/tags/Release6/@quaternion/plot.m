%PLOT	plot a quaternion object as a rotated coordinate frame

%	Copright (C) Peter Corke 1999
function plot(Q)
	axis([-1 1 -1 1 -1 1])


	o = [0 0 0]';
	x1 = Q*[1 0 0]';
	y1 = Q*[0 1 0]';
	z1 = Q*[0 0 1]';

	hold on
	plot3([0;x1(1)], [0; x1(2)], [0; x1(3)])
	text(x1(1), x1(2), x1(3), 'X')
	plot3([0;y1(1)], [0; y1(2)], [0; y1(3)])
	text(y1(1), y1(2), y1(3), 'Y')
	plot3([0;z1(1)], [0; z1(2)], [0; z1(3)])
	text(z1(1), z1(2), z1(3), 'Z')
	grid on
	xlabel('X')
	ylabel('Y')
	zlabel('Z')
	hold off
