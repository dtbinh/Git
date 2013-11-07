function plotHoughLines(image, lines)

% PLOTHOUGHLINES Draw lines over an image
%    PLOTHOUGHLINES(image, lines) displays the image and draws the lines
%    over it.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: HOUGHLINES

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 29-October-2013


% Plot the image
figure;
idisp(image, 'plain');
set(gca,'position',[0 0 1 1],'units','normalized')
hold on;

% Measure the image size and the amount of lines to be drawn
[nRow, nColumn] = size(image);
[~, nLine] = size(lines);

% Initialize arrays xLine and yLine for drawing one line
xLine = [0 0];
yLine = [0 0];

% For each line in 'lines':
for iLine = 1:nLine
    
    % Get the line parameter - rho and theta
    rho = lines(iLine).rho;
    theta = lines(iLine).theta;
    
    % If the line is horizontal, there is nothing to calculate
    if(theta == 0)
        plot([1 nColumn], [rho rho], 'r-');
    
    % If the line is not horizontal
    else
   
        % Calculate the line parameters so that x = ay + b
        a = -cos(theta)/sin(theta);
        b = rho/sin(theta);
        
        % Set the iPoint index for clearing the arrays xLine and yLine
        iPoint = 1;
        
        % Find the two points of the image boundary that intercepts the
        % line. OBS: These points can be in any of the four image edges
        % (up, down, right or left)
        
        % Search the intersection UP
        y = round((1 - b)/a);
        if(y >= 1 && y <= nRow)
            xLine(iPoint) = 1;
            yLine(iPoint) = y;
            iPoint = iPoint+1;
        end
        
        % Search the intersection DOWN
        y = round((nColumn - b)/a);
        if(y >= 1 && y <= nRow)
            xLine(iPoint) = nColumn;
            yLine(iPoint) = y;
            iPoint = iPoint+1;
        end
        
        % Search the intersection LEFT
        x = round(a * 1 + b);
        if(x >= 1 && x <= nColumn)
            xLine(iPoint) = x;
            yLine(iPoint) = 1;
            iPoint = iPoint+1;
        end
        
        % Search the intersection RIGHT
        x = round(a * nRow + b);
        if(x >= 1 && x <= nColumn)
            xLine(iPoint) = x;
            yLine(iPoint) = nRow;
        end
        
        % Draw the line between the two found points
        plot(xLine, yLine, 'r-');
    end
end