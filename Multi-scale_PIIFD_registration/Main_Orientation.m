%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function kps_new = Main_Orientation(kps,mag,angle,W,NBO)
W = round(W);
patch_size = W*2+1;
X = -W : W;  % 邻域x坐标
Y = -W : W;  % 邻域y坐标
[XX,YY] = meshgrid(X,Y);
Wcircle = ((XX.^2 + YY.^2) < (W+1)^2)*1.0;  % 圆形窗
% Wgauss = fspecial('gaussian',[patch_size,patch_size], W/3).*Wcircle;

angle = floor(angle*NBO/pi)+1;  % 取值范围：[1,NBO] & 0 表示不统计
weight = zeros(patch_size+1,patch_size+1);

o_thr = 0.8;
kps_new = [];
for k = 1:size(kps,1)
    x = kps(k,1); x1 = max(1,x-W); x2 = min(x+W,size(angle,2));
    y = kps(k,2); y1 = max(1,y-W); y2 = min(y+W,size(angle,1));
    angle_bin = zeros(patch_size,patch_size);  % 0 表示不统计
    angle_bin(W+y1-y+1:W+y2-y+1, W+x1-x+1:W+x2-x+1) = angle(y1:y2, x1:x2);
    angle_bin = angle_bin .* Wcircle;  % 圆形区域
    weight(W+y1-y+1:W+y2-y+1, W+x1-x+1:W+x2-x+1) = mag(y1:y2, x1:x2);

    o_hist = zeros(1,NBO);
    for xx = 1:patch_size
        for yy = 1:patch_size
            o_temp = angle_bin(xx,yy);
            if o_temp>0
                o_hist(o_temp) = o_hist(o_temp) + weight(xx,yy);
            end
        end
    end

    max_thr = o_thr*max(o_hist);
    for o = 1:NBO
        if(o==1)
            aa = o_hist(NBO);
        else
            aa = o_hist(o-1);
        end
        oo = o_hist(o);
        if(o==NBO)
            bb = o_hist(1);
        else
            bb = o_hist(o+1);
        end
        if(oo>aa && oo>bb && oo>max_thr)
            o_bin = o + 0.5*(aa-bb)/(aa+bb-2*oo);
            o_bin = mod(o_bin-1,NBO)+1;
            orient = o_bin*(pi/NBO);
            kps_new = [kps_new; [kps(k,:),orient]];
        end
    end
end