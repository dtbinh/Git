classdef HomMinSymAUKF < AUKF
    
%
%   CLASS DESCRIPTION
%
    
% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014
      
    % Implementation of abstract methods
    methods
        
        % Generate the sigma points using the homogeneous minimal symmetric
        % method (N = 2n+1)
        function [sigmaPoint weight] = generateSigmaPoints(obj, xAug, PAug)
            
            n = length(xAug);
            w0 = 1 - n/3;
            
            weight = (1-w0)/(2*n) * ones(1, 2*n+1);
            weight(1) = w0;
            
            matrix = (n/(1-w0))*PAug;
            Proot = sqrtm((n/(1-w0))*PAug);
            
            sigmaPoint = zeros(n, 2*n+1);
            sigmaPoint(:,1) = xAug;
            for i = 1:n
               sigmaPoint(:,1+i) = xAug + Proot(:,i);
               sigmaPoint(:,1+i+n) = xAug - Proot(:,i);
            end
        end
    end
    
    % Subclass constructor method
    methods
        function obj = HomMinSymAUKF(f, fParam, h, hParam, Q, R, dimX, dimZ)
            obj = obj@AUKF(f, fParam, h, hParam, Q, R, dimX, dimZ);            
        end
    end
end