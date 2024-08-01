%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [matches, num_keys] = Match_Keypoints(descriptor_1,descriptor_2)
warning off
kps1 = descriptor_1(:,1:5); des1 = descriptor_1(:,6:end); clear descriptor_1;
kps2 = descriptor_2(:,1:5); des2 = descriptor_2(:,6:end); clear descriptor_2;

%% Match the keypoints
[indexPairs,~] = matchFeatures(des1,des2,'MaxRatio',1,'MatchThreshold',100);
cor1_o = kps1(indexPairs(:,1),:);
cor2_o = kps2(indexPairs(:,2),:);
[cor2_o,indexPairs] = unique(cor2_o,'rows');
num_keys = size(cor2_o,1);
if(num_keys<4)
    num_keys = 0; matches = []; return
end
cor1_o = cor1_o(indexPairs,:);

%% Remove incorrect matches
[cor1,cor2,~] = Outlier_Removal(cor1_o,cor2_o,5);
num_keys = size(cor1,1);
if(num_keys<4)
    num_keys = 0; matches = []; return
end
matches = [cor1,cor2];