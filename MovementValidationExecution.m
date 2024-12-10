function [x_new, y_new, angle] = MovementValidationExecution(x, y, angle, speed, allowed, forbidden)
%{

functionality:
    - compute the new ant position.
    - if the new position is valid, return the new position. else, keep the
    current position, and only change the angle by 180 degrees.

outputs:
    x_new: new x of ant
    y_new: new y of ant
    angle: new angle of ant

inputs:
    x: the x of ant
    y: the y of ant
    angle: ant current angle
    speed: ant speed
    allowed: a matrix of 1 rows and 4 columns, containing lower left and 
        upper right points of the map
    forbidden: a matrix of N rows and 4 columns, containing lower left and 
        upper right points of the walls

%}

% your code here...

x_new = x + speed * cos(angle);
y_new = y + speed * sin(angle);

valid = 1; % true

% check if x_new and y_new are inside the map. If they are not, we chnge
% valid to 0.
if (x_new < allowed(1) || x_new > allowed(3) || y_new < allowed(2) || y_new > allowed(4))
    valid = 0; % Invalid if out of map bounds
end


% For EXTRA CREDIT, check if x_new and y_new are not on the walls. If they
% are, we change valid to 0.
for i = 1:size(forbidden, 1)
    if (x_new >= forbidden(i, 1) && x_new <= forbidden(i, 3)) && ...
       (y_new >= forbidden(i, 2) && y_new <= forbidden(i, 4))
        valid = 0; % Invalid if the position is within a wall
        break; % Exit the loop as soon as one wall is hit
    end
end

if valid
    return % already compute the new position and angle is unchanged
else
    % we maintain the previous position but angle is changed by 2*pi
    x_new = x;
    y_new = y;
    angle = mod(angle + pi, 2*pi); % mod()
end

end




