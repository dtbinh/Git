function [policy Q] = monteCarlo(epsilon, maxStep, maxEpisode)

% MOTECARLO Applies the Monte Carlo RL algorithm to the Windy Gridworld problem
%    [P Q] = MOTECARLO(E,M,N) applies the Monte Carlo method to the
%    Reinforcement Learning problem of moving in the Windy Gridworld. The
%    problem consists in learning the best policy P and the associated
%    value function Q for reaching a target location in the Windy Gridworld.
%
%    The policy used is an epsilon-greedy one, but if the goal location is
%    not reached in a maximum number of steps, the episode ends anyway. Each
%    movement has a -1 reward associated, without discount factor. There
%    are no other rewards in the world, so the return value associated with
%    each episode is -S, where S is the amount of necessary steps taken to
%    arrive at the goal location.
%
%    The training parameters are:
%        E - Epsilon: the probability of taking a random valid action,
%            instead of following the policy
%        M - Maximum Step: Maximum duration of one episode, even if the
%            goal location is not reached.
%        N - Training duration, given in number of episodes
%
%
%    Other m-files required: initPolicy.m, initValueFunction.m,
%    randomValidAction.m, nextState.m, randArgMax.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: SARSA, QLEARNING, INITVALUEFUNCTION, INITPOLICY, NEXTSTATE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013


% World Description
xMax = 7;
yMax = 10;
xStart = 4;
yStart = 1;
xGoal = 4;
yGoal = 8;
wind = [0 0 0 1 1 1 2 2 1 0];

% Initialize training data structures
policy = initPolicy(xMax, yMax);
Q = initValueFunction(xMax, yMax);
QCount = zeros(xMax, yMax, 8);

% Variables for keeping track of the performance
updateRate = 200;
plotFigure = figure();
performance = zeros(1, maxEpisode);
avgPerformance = zeros(1, maxEpisode);
bestPerformance = zeros(1, maxEpisode);

% For each episode:
for iEpisode = 1:maxEpisode
    
    % Go to the starting position
    iStep = 0;
    x = xStart;
    y = yStart;
    
    % Initialize the event list
    e.x = 0;
    e.y = 0;
    e.a = 0;
    eventList = repmat(e, 1, maxStep);
    
    % Run the episode until the goal position is reached or the maximum
    % number of steps is achieved
    while(iStep < maxStep && ~(x == xGoal && y == yGoal))

        % Randomly select between following the policy or not
        if(rand > epsilon)
            a = policy(x,y);
        else
            a = randomValidAction(x,y, xMax,yMax);
        end
        
        % Store the current event
        iStep = iStep + 1;
        eventList(iStep).x = x;
        eventList(iStep).y = y;
        eventList(iStep).a = a;
        
        % Calculate the next state
        [x y] = nextState(x, y, a, wind);
    end
    
    % Upadte the value function
    visitedStates = zeros(xMax, yMax, 8);
    for i = 1:iStep        
        
        % For each unvisited state in the event list
        x = eventList(i).x;
        y = eventList(i).y;
        a = eventList(i).a;
        if(visitedStates(x, y, a) == 0)
            
            % Update the value function
            Q(x,y,a) = (QCount(x,y,a)*Q(x,y,a) - iStep) / (QCount(x,y,a)+1);
            QCount(x,y,a) = QCount(x,y,a)+1;
            visitedStates(x,y,a) = 1;
        end
    end
    
    % Update the policy
    for iRow = 1:xMax
        for iColumn = 1:yMax
            policy(iRow, iColumn) = randArgMax(Q(iRow, iColumn, :));
        end
    end
    
    % Measure the current performance
    performance(iEpisode) = iStep;
    avgPerformance(iEpisode) = round(mean(performance(max(iEpisode-20,1):iEpisode)));
    bestPerformance(iEpisode) = min(performance(1:iEpisode));
    
    % Update the performance graph
    if(mod(iEpisode, updateRate) == 0)
        figure(plotFigure);
        hold off;
        yaxis([0 100]);
        plot(avgPerformance(1:iEpisode));
        hold on;
        plot(bestPerformance(1:iEpisode), 'r-.');
        legend('média','mínima');
        pause(0.1);
    end
        
end