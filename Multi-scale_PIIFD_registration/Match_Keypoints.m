%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [matches, num_keys] = Match_Keypoints(descriptor_1,descriptor_2)
kps1 = descriptor_1(:,1:5); des1 = descriptor_1(:,6:end); clear descriptor_1;
kps2 = descriptor_2(:,1:5); des2 = descriptor_2(:,6:end); clear descriptor_2;

%% Match the keypoints
[indexPairs,~] = matchFeatures(des1,des2,'MaxRatio',1,'MatchThreshold',100);
cor1 = kps1(indexPairs(:,1),:);
cor2 = kps2(indexPairs(:,2),:);
[cor2,indexPairs] = unique(cor2,'rows');
num_keys = size(cor2,1);
if(num_keys<4)
    num_keys = 0; matches = []; return
end
cor1 = cor1(indexPairs,:);

%% Remove incorrect matches
[cor1,cor2,~] = Outlier_Removal(cor1,cor2,5);
num_keys = size(cor1,1);
if(num_keys<4)
    num_keys = 0; matches = []; return
end
matches = [cor1,cor2];