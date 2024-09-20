%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [magnitude,angle,Theta] = Average_Squared_Grad(I,scale,int_flag)
h = [-1,0,1; -2,0,2; -1,0,1];
Gx = imfilter(I, h , 'replicate');
Gy = imfilter(I, h', 'replicate');
[M,N] = size(I); clear I

if int_flag
    magnitude = ones(M,N);
else
    magnitude = sqrt(Gx.^2 + Gy.^2);
end
angle = mod(atan2(Gy,Gx), pi);
    
h = fspecial('gaussian',[scale,scale], scale/6);
Gxx = imfilter(Gx.*Gx, h, 'replicate');
Gyy = imfilter(Gy.*Gy, h, 'replicate');
Gxy = imfilter(Gx.*Gy, h, 'replicate');
Theta = atan2(2*Gxy, Gxx-Gyy)/2 + pi/2;  % Theta¡Ê[0,pi]
Theta = mod(Theta, pi);