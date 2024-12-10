function [pheromone, concentration] = PheromonesUpdate(pheromone, concentration, decay)
%{

functionality:
    reduce all concentrations by decay, and only keep the pheromones with
    positive concentration.

outputs:
    pheromone: list of all modified pheromones
    concentration: list of all new pheromone concentrations

inputs:
    pheromone: list of all pheromones
    concentration: list of all pheromone concentrations
    decay: the concentration decay value

%}

% your code here...
% Reduce all concentrations by the decay value
    concentration = concentration - decay;

    % Only keep pheromones with positive concentrations
    valid_indices = find(concentration > 0);
    pheromone = pheromone(valid_indices, :);
    concentration = concentration(valid_indices);

end