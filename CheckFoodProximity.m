function [food_sources, indicator] = CheckFoodProximity(x, y, food_sources, food_proximity_threshold)
%{

functionality:
    compute the distance between the ant location and all food sources.
    find the nearest food source.
    if the distance is less than a threshold, remove that source from the
    foods list, and return 1. else, return 0.

outputs:
    food_sources: the (probably) modified list of food sources.
    indicator: 1, if the ant is near a food source, and 0 else.

inputs:
    x: the x of ant
    y: the y of ant
    food_sources: the list of food sources
    food_proximity_threshold: the threshold to determine proximity

%}

% your code here...
 % Compute the distances between the ant and all food sources
    distances = sqrt((food_sources(:, 1) - x).^2 + (food_sources(:, 2) - y).^2);

    % Find the nearest food source
    [min_distance, nearest_idx] = min(distances);

    % Check if the nearest food source is within the proximity threshold
    if min_distance < food_proximity_threshold
        % Remove the food source from the list
        food_sources(nearest_idx, :) = [];
        % Set the indicator to 1 (ant is near a food source)
        indicator = 1;
    else
        % No food source is close enough
        indicator = 0;
    end

end