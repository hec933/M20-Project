function [indicator] = CheckColonyProximity(x, y, colony_pos, colony_proximity_threshold)
%{

functionality:
    compute the distance between the ant location and the colony. If the
    distance is less than a threshold, ant is near colony and therefore drops food if it carries it.

outputs:
    indicator: 1, if the ant is near colony, and 0 else.

inputs:
    x: the x of ant
    y: the y of ant
    colon_pos: colony position
    colony_proximity_threshold: the threshold to determine proximity

%}

% your code here...
% Compute the distance between the ant and the colony
    distance = sqrt((colony_pos(1) - x)^2 + (colony_pos(2) - y)^2);

    % Check if the distance is less than the proximity threshold
    if distance < colony_proximity_threshold
        % Ant is near the colony
        indicator = 1;
    else
        % Ant is not near the colony
        indicator = 0;
    end
end