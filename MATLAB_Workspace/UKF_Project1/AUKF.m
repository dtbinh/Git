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
        
        c;          % UT method selection (common UT: c=3)
        ka;         % Augmented UT parameter (ka = c-dimX-dimQ-dimR)
    end
    
    % Abstract Methods - must be implemented in each subclass of AUKF
    methods (Abstract)
        
        % Generate the set of sigma points using the augmented state vector
        % according to a specific sigma point calculation method
        [sigmaPoint weight] = generateSigmaPoints(obj, xAug, PAug);
    end
    
    % Concrete Methods - behave excatly the same for all subclasses of AUKF
    methods
        
        % Class constructor
        function obj = AUKF(f, fParam, h, hParam, Q, R, dimX, dimZ, c)
            
            obj.dimX = dimX;
            obj.dimZ = dimZ;
            obj.dimQ = length(Q);
            obj.dimR = length(R);
            
            obj.x = zeros(dimX, 1);
            obj.P = zeros(dimX, dimX);
            obj.c = c;
            obj.ka = c-dimX-obj.dimQ-obj.dimR;
            
            obj.f = f;
            obj.fParam = fParam;
            obj.h = h;
            obj.hParam = hParam;
            obj.Q = Q;
            obj.R = R;
        end
        
        
        % Update the state vector by performing one iteration of the AUKF
        function obj = update(obj, u, z)
            
            % Augment the state vector
            xAug = [obj.x'                zeros(1, obj.dimQ)        zeros(1,obj.dimR)]';
            PAug = [obj.P                     zeros(obj.dimX, obj.dimQ) zeros(obj.dimX, obj.dimR);
                    zeros(obj.dimQ, obj.dimX) obj.Q                     zeros(obj.dimQ, obj.dimR);
                    zeros(obj.dimR, obj.dimX) zeros(obj.dimR, obj.dimQ) obj.R                    ];
            
            % Calculate the sigma points and corresponding weights
            [sigmaPoint weight] = obj.generateSigmaPoints(obj, xAug, PAug);
            nSigmaPoint = size(sigmaPoint, 2);
            
            % [PREDICTION STEP]
            % Transform the sigma points using the process function
            transformedSigmaPoint = feval(obj.f, sigmaPoint, u, obj.fParam);
            stateSigmaPoint = transformedSigmaPoint(1:obj.dimX,:);
            
            % Calculate the expected state mean and covariance
            xEst = sum(stateSigmaPoint .* repmat(weight, obj.dimX, 1), 2);
            PEst = zeros(obj.dimX, obj.dimX);
            varianceStateSigmaPoint = stateSigmaPoint - repmat(xEst, 1, nSigmaPoint);
            for iPoint = 1:nSigmaPoint
                PEst = PEst + weight(iPoint)*(varianceStateSigmaPoint(:,iPoint) * varianceStateSigmaPoint(:,iPoint)');
            end
            
            % [MEASUREMENT STEP]
            % Evaluate the sigma points using the observation function
            measurementSigmaPoint = feval(obj.h, transformedSigmaPoint, obj.hParam);
            
            % Calculate the expected measurement and innovation matrix
            zEst = sum(measurementSigmaPoint .* repmat(weight, obj.dimZ, 1), 2);
            S = zeros(obj.dimZ, obj.dimZ);
            varianceMeasurementSigmaPoint = measurementSigmaPoint - repmat(zEst, 1, nSigmaPoint);
            for iPoint = 1:nSigmaPoint
                S = S + weight(iPoint)*(varianceMeasurementSigmaPoint(:,iPoint) * varianceMeasurementSigmaPoint(:,iPoint)');
            end
            
            % [CORRECTION STEP]
            crossVariance = zeros(obj.dimX, obj.dimZ);
            for iPoint = 1:nSigmaPoint
                crossVariance = crossVariance + weight(iPoint)*(varianceStateSigmaPoint(:,iPoint) * varianceMeasurementSigmaPoint(:,iPoint)');
            end
            G = crossVariance / S;
            obj.x = xEst + G*(z-zEst);
            obj.P = PEst - G*S*G';
        end
        
    end
    
end