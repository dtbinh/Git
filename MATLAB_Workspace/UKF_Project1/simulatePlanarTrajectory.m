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

% tipX2 = zeros(1, nStep);
% tipY2 = zeros(1, nStep);
% tipAngle2 = zeros(1, nStep);

% Open the plot figure
if(plotSimulation)
    plotFigure = figure;
%     plotFigure2 = figure;
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
    
%     %% DEBUG
%     if(iStep > 1)
%         px    = tipX2(iStep-1);
%         py    = tipY2(iStep-1);
%         theta = tipAngle2(iStep-1);
%     else
%         px = 0;
%         py = 0;
%         theta = 0;
%     end
%     tipCurv = k(iStep);
%     u     = U1(iStep);
%     
%     tipX2(iStep) = px + (2 * (1 - cos(tipCurv .* u)) ./ (tipCurv.^2)).^(0.5) .* cos(theta + 0.5 .* u .* tipCurv);
%     tipY2(iStep) = py + (2 * (1 - cos(tipCurv .* u)) ./ (tipCurv.^2)).^(0.5) .* sin(theta + 0.5 .* u .* tipCurv);
%     tipAngle2(iStep) = theta + tipCurv .* u;
% 
%     if(plotSimulation)
%         if(mod(iStep,20) == 0)
%             figure(plotFigure2); hold on;
%             plot(tipX2(1:iStep), tipY2(1:iStep), 'b');
%             pause(0.0001)
%             axis equal;
%         end
%     end    
    
end