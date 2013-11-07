function [lineArray H rho theta] = houghLines(varargin)

% HOUGHLINES Find straight lines in an image (E. Trucco, page 99)
%    L = HOUGHLINES(image) finds straight lines in the image using the
%    Hough transform. L is a struct array containing the parameter rho and
%    theta of each line found in the Hough parametric space.
%
%    [L H R T] = HOUGHLINES(image) also returns the Hough transform H of 
%    the image and the discretized arrays R T corresponding to the
%    parameters rho and theta
%
%    L = HOUGHLINES(image, param1, value1, param2, value2, ...) allows
%    specifying the algorithm parameter. Parameters non specified assume
%    their default values. The available parameters are:
%
%        thetaStep   - the angle difference between two elements of the
%                      discretized theta array
%        rhoStep     - the distance between two elements of the discretized
%                      rho array
%        linesThresh - the threshold value for discarding weak lines
%        maxLines    - the maximum number of desired lines. Only the
%                      strongest maxLines are returned
%        NHood       - The neighborhood width for supressing non local
%                      maximum supression of lines
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: PLOTHOUGHLINES

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 29-October-2013

%% Default parameters
thetaStep = pi/180;
rhoStep = 5.0;
lineThreshold = 10;
maxLines = 1000;
neighborhoodSize = 3;

%% Decode the varargin inputs

% The edge image where the lines are supposed to be searched
edges = varargin{1};

% Algorithm parameters
for iArgin = 1:(nargin-1)/2
    if(strcmp(varargin{2*iArgin},'thetaStep'))
        thetaStep = varargin{2*iArgin+1} * pi/180;
    elseif(strcmp(varargin{2*iArgin},'rhoStep'))
        rhoStep = varargin{2*iArgin+1};        
    elseif(strcmp(varargin{2*iArgin},'lineThresh'))
        lineThreshold = varargin{2*iArgin+1};
    elseif(strcmp(varargin{2*iArgin},'maxLines'))
        maxLines = varargin{2*iArgin+1};
    elseif(strcmp(varargin{2*iArgin},'NHood'))
        neighborhoodSize = varargin{2*iArgin+1};
    end
end

%% Generate the discretized rho and theta arrays

% measure the image size
[nRow nColumn] = size(edges);

% generate rho and theta
maxRho = sqrt(nRow^2 + nColumn^2);
theta = -pi/2:thetaStep:pi/2-thetaStep;
rho = -maxRho:rhoStep:maxRho;

% measure the amount of elements in rho and theta
nTheta = size(theta,2);
nRho = size(rho,2);

% initialize the accumulators matrix for storing the Hough transform of the
% image
houghAccumulator = zeros(nRho, nTheta);

%% Locate the pixels where edges(i,j) = 1
[xEdge yEdge] = find(edges == 1);
[nEdge ~] = size(xEdge);

% For each pixel:
for iEdge = 1:nEdge
   for iTheta = 1:nTheta   
       
       % Calculate the value of rho corresponding to each theta
       currentRho = xEdge(iEdge) * cos(theta(iTheta)) + yEdge(iEdge) * sin(theta(iTheta));

        % increment the given accumulator
       [~, iRho] = min(abs(rho - currentRho));
       houghAccumulator(iRho, iTheta) = houghAccumulator(iRho, iTheta) + 1;
   end
end

% Return the obtained Hough transform before starting to supress non local
% maximums
H = houghAccumulator;

%% Supress non local maximum lines

% Initialize the lineArray and the line index
iLine = 1;
lineArray(1) = struct('value',0, 'rho',0, 'theta',0, 'theta_deg', 0);

% Find the highest peak to start the algorithm
maxAccumulator = max(max(houghAccumulator));

% When the highest peak is lower than the threshold, stop adding elements
% to the line array
while(maxAccumulator > lineThreshold)
    
    % Find the coordinates rho and theta corresponding to the highest peak
    [iRho iTheta] = find(houghAccumulator == maxAccumulator);
    
    % Add one line to the line array
    lineArray(iLine) = struct('value',maxAccumulator, 'rho',rho(iRho(1)), 'theta',theta(iTheta(1)), 'theta_deg', (180/pi)*theta(iTheta(1)));
    
    % Increment the line index
    iLine = iLine + 1;
    
    %% Suppres all lines in the neighbourhood of the added line
    
    % Calculate the range of rho inside the supression window
    rhoMin = max(1  , iRho(1) - 2*neighborhoodSize);
    rhoMax = min(nRho, iRho(1) + 2*neighborhoodSize);
    for jRho = rhoMin:rhoMax
        
        % Calculate the range of theta inside the supression window
        thetaMin = iTheta(1) - 2*neighborhoodSize;
        thetaMax = iTheta(1) + 2*neighborhoodSize;
        for jTheta = thetaMin:thetaMax
            
            % The theta window should be circular as a line of parameters 
            % (R, pi/2) is adjacent to the line (-R, -pi/2)
            if(jTheta < 1)
                currentTheta = jTheta + nTheta;
                currentRho = nRho - jRho;
            elseif(jTheta > nTheta)
                currentTheta = jTheta - nTheta;
                currentRho = nRho - jRho;
            else
                currentTheta = jTheta;
                currentRho = jRho;
            end
            
            % Erase the line from the Hough transform
            houghAccumulator(currentRho, currentTheta) = 0;
        end
    end
    
    % If enough lines have been identified, stop searching for more lines
    if(iLine <= maxLines)
        % Find the next peak to proceed with the algorithm
        maxAccumulator = max(max(houghAccumulator));
    else
        break;
    end
end
