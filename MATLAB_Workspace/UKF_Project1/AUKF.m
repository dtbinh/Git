classdef AUKF
    
%
%   CLASS DESCRIPTION
%
    
% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014
    
    properties
        x;          % state vector
        P;          % state error covariance matrix
        dimX;       % dimension of the state vector
        dimZ;       % dimension of the measurement vector
        
        f;          % state transition function
        fParam;     % parameters of the state transition function
        Q;          % covariance of the process noise
        dimQ;       % dimension of the proccess noise
        
        h;          % observation function
        hParam;     % parameters of the observation function
        R;          % covariance of the observation noise
        dimR;       % dimension of the measurement noise
    end
    
    % Abstract Methods - must be implemented in each subclass of AUKF
    methods (Abstract)
        
        % Generate the set of sigma points using the augmented state vector
        % according to a specific sigma point calculation method
        [sigmaPoint weight] = generateSigmaPoints(obj, xAug, PAug);
    end
    
    % Static Methods - auxiliar functions that do not deppend on the object
    methods (Static)
        
        % Agument the state vector incorporating the proccess noise (Q) and
        % the measurement noise (R)
        function [xAug PAug] = augmentStateVector(x, P, Q, R)
            sX = length(P); sQ = length(Q); sR = length(R);
            xAug = [x'             zeros(1, sQ)  zeros(1, sR)]';
            PAug = [P             zeros(sX, sQ) zeros(sX, sR);
                    zeros(sQ, sX) Q             zeros(sQ, sR);
                    zeros(sR, sX) zeros(sR, sQ) R            ];
        end
        
        % Transform one set of sigma points according to a given function
        % and calculate the weighted mean and covariance of the transformed
        % sigma points
        function [newSigmaPoint avg var] = transformSigmaPoints(sigmaPoint, weight, transFunction, parameters)
            
            % Transform the sigma points
            newSigmaPoint = feval(transFunction, sigmaPoint, parameters);
            [dimSigma nSigmaPoint] = size(newSigmaPoint);
            
            % Calculate the weighted mean and covariance
            avg = sum(newSigmaPoint .* repmat(weight, dimSigma, 1), 2);
            var = zeros(dimSigma, dimSigma);
            for iPoint = 1:nSigmaPoint
                var = var + weight(iPoint)*((newSigmaPoint(:,iPoint)-avg)*(newSigmaPoint(:,iPoint)-avg)');
            end        
            
        end
    end
    
    % Concrete Methods - behave excatly the same for all subclasses of AUKF
    methods
        
        % Class constructor
        function obj = AUKF(f, fParam, h, hParam, Q, R, dimX, dimZ)
            
            obj.dimX = dimX;
            obj.dimZ = dimZ;
            obj.dimQ = length(Q);
            obj.dimR = length(R);
            
            obj.x = zeros(dimX, 1);
            obj.P = zeros(dimX, dimX);
            
            obj.f = f;
            obj.fParam = fParam;
            obj.h = h;
            obj.hParam = hParam;
            obj.Q = Q;
            obj.R = R;
        end
        
        % Apply the filter's proccess function F to the set of sigma points
        % calculate the expected state mean and covariance
        function [processSigmaPoint xEst PEst] = applyProcessFunction(obj, sigmaPoint, weight, u)
            [processSigmaPoint xEst PEst] = AUKF.transformSigmaPoints(sigmaPoint, weight, obj.f, [obj.fParam u']);
            xEst = xEst(1:obj.dimX, :);
            PEst = PEst(1:obj.dimX, 1:obj.dimX);
        end
        
        % Apply the filter's observation function H to the set of sigma points
        % calculate the expected measurement and innovation matrix
        function [measurementSigmaPoint zEst S] = applyMeasurementFunction(obj, processSigmaPoint, weight)
            [measurementSigmaPoint zEst S] = AUKF.transformSigmaPoints(processSigmaPoint, weight, obj.h, obj.hParam);
        end
        
        % Update the state vector by performing one iteration of the AUKF
        function obj = update(obj, u, z)
            
            % Augment the state vector
            [xAug PAug] = AUKF.augmentStateVector(obj.x, obj.P, obj.Q, obj.R);
            
            % Calculate the sigma points and corresponding weights
            [sigmaPoint weight] = obj.generateSigmaPoints(xAug, PAug);
            nSigmaPoint = size(sigmaPoint, 2);
            
            % Prediction Step
            [processSigmaPoint xEst PEst] = obj.applyProcessFunction(sigmaPoint, weight, u);            
            
            % Measurement Step
            [measurementSigmaPoint zEst S] = obj.applyMeasurementFunction(processSigmaPoint, weight);
            
            % Correction Step
            crossVariance = zeros(obj.dimX, obj.dimZ);
            stateVariance = processSigmaPoint(1:obj.dimX,:) - repmat(xEst, 1, nSigmaPoint);
            measurementVariance = measurementSigmaPoint - repmat(zEst, 1, nSigmaPoint);
            for iPoint = 1:nSigmaPoint
                crossVariance = crossVariance + weight(iPoint)*(stateVariance(:,iPoint) * measurementVariance(:,iPoint)');
            end
            G = crossVariance / S;
            obj.x = xEst + G*(z-zEst);
            obj.P = PEst - G*S*G';
        end
        
    end
    
end