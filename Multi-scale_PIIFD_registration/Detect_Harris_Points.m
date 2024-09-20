%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function kps = Detect_Harris_Points(I,scale,thresh,radius,N,nOctaves,G_resize,disp)
%% Image norm and mask
I = I - min(I(:));
I = (I/mean(I(:))/2)*255;
msk = Mask(I,0);

%% Harris corner detectation
kps = Harris(I,scale,thresh,radius);

%% Post-processing
kps = Remove_Boundary_Points(kps,msk,max(scale,G_resize^(nOctaves-2)));
if size(kps,1)<10
    kps = []; return
end
kps = sortrows(kps,-3);
kps = kps(1:min(N,size(kps,1)),:);

%% Show detected keypoints
if disp==1
    figure, imshow(I,[]), hold on, plot(kps(:,1),kps(:,2),'r.');
%     for i=1:size(kps,1)
%         text(kps(i,1),kps(i,2),num2str(i),'color','y');
%     end
    title(['Detected Harris keypoints: ',num2str(size(kps,1))]); drawnow
end


function msk = Mask(I,th)
I = I./max(I(:))*255;
msk = double(I>th);
h = D2gauss(7,4,7,4,0);
msk = (conv2(msk,h,'same')>0.8);


function p = Remove_Boundary_Points(loc,msk,s)
se = strel('disk',s);
msk = ~(imdilate(~msk,se));
p = [];
for i = 1:size(loc,1)
    if msk(loc(i,2),loc(i,1)) == 1
        p = [p;loc(i,:)];
    end
end