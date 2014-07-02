function [tipX tipY tipAngle] = simulatePlanarTrajectory(U1, U2, k, varargin)

if(nargin > 3)
    plotSimulation = 1;
else
    plotSimulation = 0;
end

% Initialize vectors for storing the tip location
nStep = length(U1);
tipX = zeros(1, nStep);
tipY = zeros(1, nStep);
tipAngle = zeros(1, nStep);
dq{1} = DQ(1);

% Open the plot figure
if(plotSimulation)
    plotFigure = figure;
end

% Simulation loop
for iStep = 1:nStep
    
    % Apply Input
    if(U1(iStep) > 0)
        A = sqrt(U2(iStep)^2+k(iStep)^2*U1(iStep)^2);
        phi = A;
        B = sin(phi/2)/A;
        r = DQ([cos(phi/2);B*U2(iStep);0;B*U1(iStep)*k(iStep)]);
        p = DQ([0;U1(iStep);0;0]);
        dqi = r + DQ.E*0.5*p*r;
        dq{iStep} = dq{end}*dqi;
    else
        dq{iStep} = dq{end};
    end
    
    p = translation(dq{iStep});
    tipX(iStep) = p.q(2);
    tipY(iStep) = p.q(3);
    if(iStep > 1)
        tipAngle(iStep) = atan2(tipY(iStep)-tipY(iStep-1), tipX(iStep)-tipX(iStep-1));
    else
        tipAngle(1) = atan2(tipY(1), tipX(1));
    end
     
    if(plotSimulation)
        if(mod(iStep,20) == 0)
            figure(plotFigure); hold on;
            plot(tipX(1:iStep), tipY(1:iStep), 'b');
            pause(0.0001)
            axis equal;
        end
    end
    
end