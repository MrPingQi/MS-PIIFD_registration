function descriptors = PIIFD_Descriptor(img, kps, kps_t,...
    scale, NBS, NBO, int_flag, rot_flag)
warning off

[M, N] = size(img); % M：height, N：width

h = [-1,0,1; -2,0,2; -1,0,1];
Ix = imfilter(img, h , 'replicate');
Iy = imfilter(img, h', 'replicate');

theta = Average_Squared_Grad(Ix,Iy,scale);
kps = [kps_t,kps];
if rot_flag
%     kps(:,5) = diag(theta(kps_t(:,2),kps_t(:,1)));  % fast
    kps = Main_Orientation(kps,theta,scale/2,NBO);
else
    kps(:,5) = 0;
end
key_num = size(kps, 1);

if int_flag
    magnitudes = ones(M,N);
else
    magnitudes = sqrt(Ix.^2 + Iy.^2);
end
angles = mod(atan2(Iy, Ix), pi);

wsigma = NBS/2; % 梯度值加权用
W = scale/2;
ss = W/2;
descriptors = zeros(key_num,NBS*NBS*NBO);
for p = 1: key_num
    magnitude = magnitudes;
    x = kps(p,1);
    y = kps(p,2);
    theta = kps(p,end);
    sinth = sin(theta);
    costh = cos(theta);
    
    % Within the patch, select the pixels within the circle and put into the histogram.
    % No need to really do rotation which is very expensive.
    pp = magnitudes(max(y-W, 1) : min(y+W, M-2), max(x-W, 1): min(x+W, N-2));
%     pp = pp./max(pp(:));
    xx = sort(pp(:));
    xind1 = round(5/6 * size(xx,1));
    xind2 = round(3/6 * size(xx,1));
    xind3 = round(2/6 * size(xx,1));
    pp = (pp>=xx(xind1)) + (pp<xx(xind1) & (pp>=xx(xind2))) .* pp + ...
         (pp<xx(xind2) & (pp>=xx(xind3))) * 0.5 .* pp;
    magnitude(max(-W, 1-y) +y: min(+W, M-2-y)+y, max(-W, 1-x)+x: min(W, N-2- x)+x) = pp;
    
    des = zeros(NBS, NBS, NBO);
    for dx = max(-W, 1-x): min(W, N -2 - x)
        for dy = max(-W, 1-y) : min(+W, M-2-y)
            mag = magnitude(y + dy, x + dx);
            angle = angles(y + dy, x + dx);
            angle = mod(angle - theta, pi); 
            
            nx = ( costh * dx + sinth * dy) / ss;
            ny = (-sinth * dx + costh * dy) / ss; 
            nt = NBO * angle / (pi);
            
            wincoef =  exp(-(nx*nx + ny*ny)/(2.0 * wsigma * wsigma));
            
            binx = floor( nx - 0.5 );
            biny = floor( ny - 0.5 );
            bint = floor( nt );
            rbinx = nx - (binx+0.5);
            rbiny = ny - (biny+0.5);
            rbint = nt - bint;
            
            for dbinx = 0:1
             for dbiny = 0:1
              for dbint = 0:1
               if (binx+dbinx >= -(NBS/2) && ...
                   binx+dbinx <   (NBS/2) && ...
                   biny+dbiny >= -(NBS/2) && ...
                   biny+dbiny <   (NBS/2) && ~isnan(bint))

                   weight = wincoef * mag ...
                            * abs(1 - dbinx - rbinx) ...
                            * abs(1 - dbiny - rbiny) ...
                            * abs(1 - dbint - rbint);

                   des(binx+dbinx+NBS/2+1, ...
                       biny+dbiny+NBS/2+1, ...
                       mod((bint+dbint),NBO)+1) = ...
                           des(binx+dbinx+NBS/2+1, ...
                               biny+dbiny+NBS/2+1, ...
                               mod((bint+dbint),NBO)+1 ) + weight;
               end
              end
             end
            end
        end
    end
    
    if rot_flag
        des_Q = imrotate(des,180);
        des_D1 = des + des_Q;
        des_D2 = abs(des - des_Q);
        des_D2 = des_D2 * max(des_D1(:))/max(des_D2(:));
        des = cat(1,des_D1(1:NBS/2,:,:),des_D2(1:NBS/2,:,:));
    end
    des = des(:);
    des = des ./ norm(des);
    descriptors(p,:) = des;
end
descriptors = [kps, descriptors];


function Theta = Average_Squared_Grad(Ix,Iy,scale)
h = fspecial('gaussian',[scale,scale], scale/6);
Ixx = imfilter(Ix.*Ix, h, 'replicate');
Iyy = imfilter(Iy.*Iy, h, 'replicate');
Ixy = imfilter(Ix.*Iy, h, 'replicate');
Theta = atan2(2*Ixy, Ixx-Iyy)/2 + pi/2;  % Theta∈[0,pi]