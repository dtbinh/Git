function plotCorrespondingPoints(imageLeft, imageRight, pointsFile)

left = iread(imageLeft, 'grey', 'double');
right = iread(imageRight, 'grey', 'double');

points = load(pointsFile);
nPoint = size(points, 1);

figureLeft = figure;
idisp(left, 'plain');
hold on;

figureRight = figure;
idisp(right, 'plain');
hold on;

for iPoint = 1:nPoint
    switch mod(iPoint, 3)
        case 0
            figure(figureLeft);
            plot(points(iPoint, 1), points(iPoint, 2), 'r*');
            figure(figureRight);
            plot(points(iPoint, 3), points(iPoint, 4), 'r*');            
        case 1
            figure(figureLeft);
            plot(points(iPoint, 1), points(iPoint, 2), 'g*');
            figure(figureRight);
            plot(points(iPoint, 3), points(iPoint, 4), 'g*');                        
        case 2
            figure(figureLeft);
            plot(points(iPoint, 1), points(iPoint, 2), 'b*');
            figure(figureRight);
            plot(points(iPoint, 3), points(iPoint, 4), 'b*');                        
    end
end