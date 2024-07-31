function [matches, num_keys] = Match_Keypoints(descriptor_1,descriptor_2)
warning off
key1 = descriptor_1(:,1:5); des1 = descriptor_1(:,6:end); clear descriptor_1;
key2 = descriptor_2(:,1:5); des2 = descriptor_2(:,6:end); clear descriptor_2;

%% Match the keypoints
[indexPairs,~] = matchFeatures(des1,des2,'MaxRatio',1,'MatchThreshold', 100);
cor1_o = key1(indexPairs(:, 1), :);
cor2_o = key2(indexPairs(:, 2), :);
[cor2_o,index] = unique(cor2_o,'rows');
cor1_o = cor1_o(index,:);
num_keys = size(cor1_o,1);
if(num_keys<4)
    num_keys = 0;
    matches = [];
    return
end

%% Remove incorrect matches
% [cor1,cor2] = Outlier_Removal_PIIFD(cor1_o(:,[3,4,1,2,5]),cor2_o(:,[3,4,1,2,5]),0.2,0.8,0.05);
% cor1 = cor1(:,[3,4,1,2,5]); cor2 = cor2(:,[3,4,1,2,5]);
[cor1,cor2,~] = Outlier_Removal_FSC(cor1_o,cor2_o,5);
num_keys = size(cor1,1);
if(num_keys<4)
    num_keys = 0;
    matches = [];
    return
end
matches = [cor1,cor2];