%RIKNDEMO Inverse kinematics demo


% Copyright (C) 1993-2011, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
% 
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

figure(2)
echo on
%
% Inverse kinematics is the problem of finding the robot joint coordinates,
% given a homogeneous transform representing the last link of the manipulator.
% It is very useful when the path is planned in Cartesian space, for instance 
% a straight line path as shown in the trajectory demonstration.
%
% First generate the transform corresponding to a particular joint coordinate,
    q = [0 -pi/4 -pi/4 0 pi/8 0]
    T = p560.fkine(q);
%
% Now the inverse kinematic procedure for any specific robot can be derived 
% symbolically and in general an efficient closed-form solution can be 
% obtained.  However we are given only a generalized description of the 
% manipulator in terms of kinematic parameters so an iterative solution will 
% be used. The procedure is slow, and the choice of starting value affects 
% search time and the solution found, since in general a manipulator may 
% have several poses which result in the same transform for the last
% link. The starting point for the first point may be specified, or else it
% defaults to zero (which is not a particularly good choice in this case)
    qi = p560.ikine(T);
    qi'
%
% Compared with the original value
    q
%
% A solution is not always possible, for instance if the specified transform 
% describes a point out of reach of the manipulator.  As mentioned above 
% the solutions are not necessarily unique, and there are singularities 
% at which the manipulator loses degrees of freedom and joint coordinates 
% become linearly dependent.
pause % any key to continue
%
% To examine the effect at a singularity lets repeat the last example but for a
% different pose.  At the `ready' position two of the Puma's wrist axes are 
% aligned resulting in the loss of one degree of freedom.
    T = p560.fkine(qr);
    qi = p560.ikine(T);
    qi'
%
% which is not the same as the original joint angle
    qr
pause % any key to continue
%
% However both result in the same end-effector position
    p560.fkine(qi) - p560.fkine(qr)
pause % any key to continue
    
% Inverse kinematics may also be computed for a trajectory.
% If we take a Cartesian straight line path
    t = [0:.056:2]; 		% create a time vector
    T1 = transl(0.6, -0.5, 0.0) % define the start point
    T2 = transl(0.4, 0.5, 0.2)	% and destination
    T = ctraj(T1, T2, length(t)); 	% compute a Cartesian path

%
% now solve the inverse kinematics.  When solving for a trajectory, the 
% starting joint coordinates for each point is taken as the result of the 
% previous inverse solution.
%
    tic
    q = p560.ikine(T); 
    toc
%
% Clearly this approach is slow, and not suitable for a real robot controller 
% where an inverse kinematic solution would be required in a few milliseconds.
%
% Let's examine the joint space trajectory that results in straightline 
% Cartesian motion
    subplot(3,1,1)
    plot(t,q(:,1))
    xlabel('Time (s)');
    ylabel('Joint 1 (rad)')
    subplot(3,1,2)
    plot(t,q(:,2))
    xlabel('Time (s)');
    ylabel('Joint 2 (rad)')
    subplot(3,1,3)
    plot(t,q(:,3))
    xlabel('Time (s)');
    ylabel('Joint 3 (rad)')

pause % hit any key to continue
    
% This joint space trajectory can now be animated
    clf
    p560.plot(q)
pause % any key to continue
echo off
