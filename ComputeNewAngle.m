function [angle] = ComputeNewAngle(x, y, ant_angle, pheromones, concentration, r_smell, sigma_1, sigma_2)

if isempty(pheromones)
    angle = ant_angle + sigma_2 * randn(); % normally distributed random value...
    return;
end


pheromones_rel = pheromones(:, 1:2) - [x, y];
pheromones_distance = sqrt(sum(pheromones_rel.^2, 2));

pheromones_angles = mod(atan2(pheromones_rel(:, 2), pheromones_rel(:, 1)), 2*pi); % mod() atan2()


valid_pheromones = pheromones((pheromones_distance <= r_smell) & (abs(mod(pheromones_angles - ant_angle + pi, 2*pi) - pi) <= pi/2)); % distance less than r_smell & difference of angle less than pi/2


valid_concentration = concentration((pheromones_distance <= r_smell) & (abs(mod(pheromones_angles - ant_angle + pi, 2*pi) - pi) <= pi/2));
pheromones_rel = pheromones_rel((pheromones_distance <= r_smell) & (abs(mod(pheromones_angles - ant_angle + pi, 2*pi) - pi) <= pi/2), :);

if isempty(valid_concentration)
    angle = ant_angle + sigma_2 * randn(); % normally distributed random value...
    return;
end



mean_pheromones = sum(pheromones_rel .* valid_concentration, 1) / sum(valid_concentration); % the weighted mean of the x and y positions.

new_angle = atan2(mean_pheromones(2), mean_pheromones(1));
angle = new_angle + sigma_1 * randn(); % mod() atan2() + % normally distributed random value...

end