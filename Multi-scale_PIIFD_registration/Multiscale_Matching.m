%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves_1,nOctaves_2,nLayers,scl_flag)
%% Matching
matches = cell(nOctaves_1,nLayers,nOctaves_2,nLayers);
confidence = zeros(nOctaves_1,nLayers,nOctaves_2,nLayers);
if scl_flag
    for octave2=1:nOctaves_2
        for octave1=1:nOctaves_1
            for layer2=1:nLayers
                for layer1=1:nLayers
    [matches{octave1,layer1,octave2,layer2},...
        confidence(octave1,layer1,octave2,layer2)] = Match_Keypoints(...
        descriptors_1{octave1,layer1},descriptors_2{octave2,layer2});
                end
            end
        end
    end
else
    for octave=1:min(nOctaves_1,nOctaves_2)
        for layer2=1:nLayers
            for layer1=1:nLayers
    [matches{octave,layer1,octave,layer2},...
        confidence(octave,layer1,octave,layer2)] = Match_Keypoints(...
        descriptors_1{octave,layer1},descriptors_2{octave,layer2});
            end
        end
    end
end
clear descriptors_1 descriptors_2;

%% Optimizing
Confidence = zeros(nOctaves_1,nOctaves_2);
cor1 = cell(nOctaves_1,nOctaves_2);
cor2 = cell(nOctaves_1,nOctaves_2);
for octave1=1:nOctaves_1
    for octave2=1:nOctaves_2
        Matches = [];
        for layer1=1:nLayers
            for layer2=1:nLayers
                Matches = [Matches; matches{octave1,layer1,octave2,layer2}];
            end
        end
        if size(Matches,1)>0
            Matches = Matches(:,[3:4,1:2,5,8:9,6:7,10]);  % Switch kps and kps_t
            [~,index1,~] = unique(Matches(:,1:2),'rows');
            Matches = Matches(index1,:);
            [~,index2,~] = unique(Matches(:,6:7),'rows');
            Matches = Matches(index2,:);
            [cor1{octave1,octave2},cor2{octave1,octave2},~] = ...
                Outlier_Removal(Matches(:,1:5),Matches(:,6:10),5);
            Confidence(octave1,octave2) = size(cor1{octave1,octave2},1);
        end
    end
end
[max_O1,max_O2] = find(Confidence==max(max(Confidence)));
cor1 = cor1{max_O1,max_O2}; cor2 = cor2{max_O1,max_O2};