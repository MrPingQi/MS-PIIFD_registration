%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptors = PIIFD_Descriptor(I, kps, ...
    patch_size, NBS, NBO, int_flag, rot_flag)

[M,N] = size(I);
W = patch_size/2;

[magnitudes,angles,theta] = Average_Squared_Grad(I,patch_size,int_flag); clear I

if rot_flag
%     kps = [kps,diag(theta(kps(:,2),kps(:,1)))];  % fast
    kps = Main_Orientation(kps,magnitudes,theta,W,NBO);
else
    kps = [kps,zeros(size(kps,1),1)];
end

wS = NBS/2;  % 梯度值加权用; gradient weighting parameters
ss = W/2;
descriptors = zeros(size(kps,1),NBS*NBS*NBO);
for k = 1:size(kps,1)
    magnitude = magnitudes;
    x = kps(k,1);
    y = kps(k,2);
    theta = kps(k,end);
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
    for dx = max(-W, 1-x): min(W, N-2-x)
        for dy = max(-W, 1-y) : min(+W, M-2-y)
            mag = magnitude(y + dy, x + dx);
            angle = angles(y + dy, x + dx);
            angle = mod(angle - theta, pi); 
            
            nx = ( costh * dx + sinth * dy) / ss;
            ny = (-sinth * dx + costh * dy) / ss; 
            nt = NBO * angle / (pi);
            
            wincoef =  exp(-(nx*nx + ny*ny)/(2.0 * wS * wS));
            
            binx = floor( nx - 0.5 );
            biny = floor( ny - 0.5 );
            bint = floor( nt );
            rbinx = nx - (binx+0.5);
            rbiny = ny - (biny+0.5);
            rbint = nt - bint;
            
            for dbinx = 0:1
             for dbiny = 0:1
              for dbint = 0:1
               if (binx+dbinx >= -wS && ...
                   binx+dbinx <   wS && ...
                   biny+dbiny >= -wS && ...
                   biny+dbiny <   wS && ~isnan(bint))

                   weight = wincoef * mag ...
                            * abs(1 - dbinx - rbinx) ...
                            * abs(1 - dbiny - rbiny) ...
                            * abs(1 - dbint - rbint);
                   
                   ind_x = binx+dbinx+wS+1;
                   ind_y = biny+dbiny+wS+1;
                   ind_o = mod((bint+dbint),NBO)+1;
                   des(ind_x,ind_y,ind_o) = des(ind_x,ind_y,ind_o) + weight;
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
    descriptors(k,:) = des;
end
descriptors = [kps, descriptors];