function [policy Q] = qLearning(epsilon, alpha, maxEpisode)

% QLEARNING Applies the Q-Learning RL algorithm to the Windy Gridworld problem
%    [P Q] = QLEARNING(E,A,N) applies the Q-Learning temporal difference 
%    method to the Reinforcement Learning problem of moving in the Windy 
%    Gridworld. The problem consists in learning the best policy P and the 
%    associatedvalue function Q for reaching a target location in the Windy 
%    Gridworld.
%
%    The policy used is an epsilon-greedy one. Each movement has a -1 
%    reward associated, without discount factor. There are no other rewards 
%    in the world,
%
%    The training parameters are:
%        E - Epsilon: the probability of taking a random valid action,
%            instead of following the policy
%        A - Learning Rate: The strength of new data, in respect with the
%            cumulated data, when updating the value function.
%        N - Training duration, given in number of episodes
%
%
%    Other m-files required: initPolicy.m, initValueFunction.m,
%    randomValidAction.m, nextState.m, randArgMax.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: MOTECARLO, SARSA, INITVALUEFUNCTION, INITPOLICY, NEXTSTATE

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

% Variables for keeping track of the performance
updateRate = 50;
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
    
    % Run the episode until the goal position is reached 
    while(~(x == xGoal && y == yGoal))

        % Randomly select between following the policy or not
        if(rand > epsilon)
            a = policy(x, y);
        else
            a = randomValidAction(x, y, xMax, yMax);
        end
         
        % Calculate the reward and the next state
        [newX newY] = nextState(x, y, a, wind);
        if(newX == xGoal && newY == yGoal)
            reward = 0;
        else
            reward = -1;
        end
        
        % Upadte the value function
        Q(x,y,a) = Q(x,y,a) + alpha*(reward + max(Q(newX,newY,:)) - Q(x,y,a));
        iStep = iStep + 1;
        
        % Go to the next state
        x = newX;
        y = newY;
        
        % Update the policy
        for iRow = 1:xMax
            for iColumn = 1:yMax
                policy(iRow, iColumn) = randArgMax(Q(iRow, iColumn, :));
            end
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
