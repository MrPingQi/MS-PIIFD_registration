function h = D2gauss(n1,std1,n2,std2,theta)

% Function "D2gauss.m":
% This function returns a 2D Gaussian filter with size n1*n2;
% theta is the angle that the filter rotated counter clockwise;
% sigma1 and sigma2 are the standard deviation of the gaussian functions.

if std1 <= 0 || std2 <= 0
    error('Standard deviations must be positive.');
end

[X, Y] = meshgrid(1:n1, 1:n2);
X = X - (n1 + 1) / 2;
Y = Y - (n2 + 1) / 2;

R = [cos(theta) -sin(theta);
     sin(theta)  cos(theta)];
rot_coords = R * [X(:)'; Y(:)'];

h = gauss(rot_coords(1,:), std1) .* gauss(rot_coords(2,:), std2);

h = reshape(h, n2, n1);
h = h / sqrt(sum(h(:).^2));
h = h / sum(h(:));


function y = gauss(x,std)
y = exp(-x.^2 / (2 * std^2)) / (std * sqrt(2 * pi));
