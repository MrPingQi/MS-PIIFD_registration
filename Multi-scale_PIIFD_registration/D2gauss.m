function h = D2gauss(n1,std1,n2,std2,theta)

% Function "D2gauss.m":
% This function returns a 2D Gaussian filter with size n1*n2;
% theta is the angle that the filter rotated counter clockwise;
% sigma1 and sigma2 are the standard deviation of the gaussian functions.

r=[cos(theta) -sin(theta);
   sin(theta)  cos(theta)];
for i = 1 : n2 
    for j = 1 : n1
        u = r * [j-(n1+1)/2 i-(n2+1)/2]';
        h(i,j) = gauss(u(1),std1)*gauss(u(2),std2);
    end
end
h = h / sqrt(sum(sum(h.*h)));
h=h/sum(sum(h));

function y = gauss(x,std)
y = exp(-x^2/(2*std^2)) / (std*sqrt(2*pi));
