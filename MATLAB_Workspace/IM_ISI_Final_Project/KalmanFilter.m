classdef KalmanFilter
    
%
%   CLASS DESCRIPTION
%

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% February 2014; Last revision: 18-February-2014
    
    properties
        x;          % state vector
        P;          % state error covariance matrix
        F;          % state transition matrix
        G;          % control input model
        H;          % observation matrix
        Q;          % covariance of the process noise
        R;          % covariance of the observation noise
        nState;     % length of state vector
        nInput;     % length of control input vector
        nSensor;    % length of observation vector
    end
    
    methods
        
        % KalmanFilter constructor - initialize the filter object
        function obj = KalmanFilter(F, G, H, Q, R)
            
            % Check the dimensions of the provided matrices
            [obj.nState obj.nInput obj.nSensor] = checkMatrixDimensions(F, G, H, Q, R);
            
            % Initialize x and P with empty values
            obj.x = zeros(obj.nState, 1);        
            obj.P = zeros(obj.nState);
            
            % Copy matrices F, G, H, Q and R to the object properties
            obj.F = F;
            obj.G = G;
            obj.H = H;
            obj.Q = Q;
            obj.R = R;
        end
        
        
        % Update the state vector by performing one prediction followed by
        % one measurement
        function obj = update(obj, u, z)
            
            % Prediction step
            xEst = obj.F * obj.x + obj.G * u;
            PEst = obj.F * obj.P * obj.F' + obj.Q;     
            
            % Measurement step
            y = z - obj.H * xEst;
            S = obj.H * PEst * obj.H' + obj.R;
            K = PEst * obj.H' / S;
            
            % Correction step
            obj.x = xEst + K * y;
            obj.P = (eye(obj.nState) - K * obj.H) * PEst;
        end
            
        
    end
    
end




function [nState nInput nSensor] = checkMatrixDimensions(F, G, H, Q, R)

nState = size(F,1);
nInput = size(G,2);
nSensor = size(H,1);

error = 0;
if(size(F,2) ~= nState) error = 1;
elseif(size(G,1) ~= nState) error = 1;
elseif(size(H,2) ~= nState) error = 1;
elseif(size(Q,1) ~= nState) error = 1;
elseif(size(Q,2) ~= nState) error = 1;
elseif(size(R,1) ~= nSensor) error = 1;
elseif(size(R,2) ~= nSensor) error = 1;    
end
    
if(error)
    nState = -1;
    nInput = -1;
    nSensor = -1;
end    

end