% Cleaning stuff
clc
clear
close all
rng(412) 

% Load the map data 
load("map2.mat")

% Map boundaries
x1 = map_coordinates(1); % Minimum x-coordinate
y1 = map_coordinates(2); % Minimum y-coordinate
x2 = map_coordinates(3); % Maximum x-coordinate
y2 = map_coordinates(4); % Maximum y-coordinate

% Colony position
x_colony = colony_pos(1); % x-coordinate of colony
y_colony = colony_pos(2); % y-coordinate of colony

% walls list
walls = [x1, y1, x2, y2]; % Boundary limits

% Fixed parameters
ants_speed = 1; 

% Customizable parameters
sigma_1 = pi/180 * 15;  % radians, randomness in following pheromones in (0, inf)
sigma_2 = pi/180 * 30; % radians, randomness in search for pheromones in (0, inf)
r_smell = 10; % Free parameter in [0,10]
blue_decay = 0.04; % Free parameter in (0,1)
red_decay = 0.06; % Free parameter in (0,1)

% Initialize ant positions, states, and angles
n_ants; % Number of ants (loaded from map data)
ants_angle = rand(n_ants, 1) * 2 * pi; % Random initial angles (0 to 2*pi)
ants_xpos = x_colony * ones(n_ants, 1); % All ants start at the colony (x-coordinate)
ants_ypos = y_colony * ones(n_ants, 1); % All ants start at the colony (y-coordinate)
ants_food = zeros(n_ants, 1); % Ants start without food (0 = no food, 1 = carrying food)

% Initialize pheromones
blue_pheromones = [x_colony, y_colony]; % Initial blue pheromone at the colony
blue_concentration = [1e6]; % High concentration for the initial blue pheromone

% Compute food center (optional, for debugging or visualization)
food_center = [mean(food_sources(:,1)), mean(food_sources(:,2))];

% Initialize red pheromones at the food sources
red_pheromones = food_sources; % Red pheromones start at food locations
initial_food_sources = food_sources; % Store initial food sources for reference
red_concentration = 1e6 * ones(size(food_sources, 1), 1); % High concentration at the start

% Colony food counter variable
food_colony_counter = 0; % Tracks how much food has been brought to the colony

v = VideoWriter('Ants_Simulation_map2.mp4', 'MPEG-4');
open(v);

% Main simulation loop (iterate over time steps)
for t = 1:T
    disp(t); % Display current time step in the console

    % Iterate over each ant to update its state
    for i_ant = 1:n_ants
        % 1. Compute the new angle
        if ants_food(i_ant) == 0
            % Ant without food follows red pheromones
            angle = ComputeNewAngle(ants_xpos(i_ant), ants_ypos(i_ant), ants_angle(i_ant), red_pheromones, red_concentration, r_smell, sigma_1, sigma_2);
        else
            % Ant with food follows blue pheromones
            angle = ComputeNewAngle(ants_xpos(i_ant), ants_ypos(i_ant), ants_angle(i_ant), blue_pheromones, blue_concentration, r_smell, sigma_1, sigma_2);
        end

        % 2. Check movement validity
        [x_new, y_new, angle] = MovementValidationExecution(ants_xpos(i_ant), ants_ypos(i_ant), angle, ants_speed, walls, []);

        % 3. Update ant location and angle
        ants_xpos(i_ant) = x_new;
        ants_ypos(i_ant) = y_new;
        ants_angle(i_ant) = angle;

        % 4. Food and colony interaction
        if ants_food(i_ant) == 0
            % Check food proximity
            [food_sources, food_indicator] = CheckFoodProximity(x_new, y_new, food_sources, food_proximity_threshold);
            if food_indicator
                ants_food(i_ant) = 1; % Ant grabs food
                ants_angle(i_ant) = mod(angle + pi, 2*pi); % Turn around
            end
        else
            % Check colony proximity
            colony_indicator = CheckColonyProximity(x_new, y_new, colony_pos, colony_proximity_threshold);
            if colony_indicator
                ants_food(i_ant) = 0; % Drop food at colony
                ants_angle(i_ant) = mod(angle + pi, 2*pi); % Turn around
                food_colony_counter = food_colony_counter + 1; % Increment food counter
            end
        end
    end

    % 5. Update pheromones 
    [blue_pheromones, blue_concentration] = PheromonesUpdate(blue_pheromones, blue_concentration, blue_decay);
    [red_pheromones, red_concentration] = PheromonesUpdate(red_pheromones, red_concentration, red_decay);

    % Remove red pheromones near depleted food sources
    depleted_food_indices = []; % Initialize an empty list for depleted food indices
    for i_food = 1:size(initial_food_sources, 1)
        if ~ismember(initial_food_sources(i_food, :), food_sources, 'rows')
            % Food source is depleted
            depleted_food_indices = [depleted_food_indices; find(ismember(red_pheromones, initial_food_sources(i_food, :), 'rows'))];
        end
    end
    red_pheromones(depleted_food_indices, :) = []; % Remove pheromones
    red_concentration(depleted_food_indices, :) = []; % Remove concentrations

    % Ants deposit new pheromones
    for i_ant = 1:n_ants
        if ants_food(i_ant) == 0
            % Ant without food drops blue pheromones
            blue_pheromones = [blue_pheromones; [ants_xpos(i_ant), ants_ypos(i_ant)]];
            blue_concentration = [blue_concentration; 1];
        else
            % Ant with food drops red pheromones
            red_pheromones = [red_pheromones; [ants_xpos(i_ant), ants_ypos(i_ant)]];
            red_concentration = [red_concentration; 1];
        end
    end

    % 6. Visualization (update the plot)
    plot(colony_pos(1), colony_pos(2), 'o', 'MarkerFaceColor', 'yellow'); % Plot colony
    grid on;
    xlim([map_coordinates(1), map_coordinates(3)]); % Set x-axis limits
    ylim([map_coordinates(2), map_coordinates(4)]); % Set y-axis limits
    pbaspect([1 1 1]); % Keep plot aspect ratio square
    hold on;
    viscircles(colony_pos, colony_proximity_threshold, 'Color', 'c'); % Visualize colony radius
    plot(food_sources(:,1), food_sources(:,2), 'vm', 'MarkerFaceColor', 'magenta'); % Plot food sources
    scatter(ants_xpos, ants_ypos, 10, 'k*'); % Plot ants
    scatter(blue_pheromones(:,1), blue_pheromones(:,2), 10, 'b', 'filled', 'MarkerFaceAlpha', 0.3); % Plot blue pheromones
    scatter(red_pheromones(:,1), red_pheromones(:,2), 10, 'r', 'filled', 'MarkerFaceAlpha', 0.3); % Plot red pheromones
    
    % Add title with the current time step and food collected
    title("T = " + t + " | Food Collected = " + food_colony_counter);
    hold off;
    pause(0.001); % Pause for visualization


    % 7. Save Video
    % Capture the current frame and write it to the video
    frame = getframe(gcf); % Capture the current figure
    writeVideo(v, frame);   % Write the frame to the video
    pause(0.001);

end
% Close the video after loop ends
pause(3);
close(v);