%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves1,nOctaves2,nLayers,Error,K,scl_flag)
%% Matching
matches = cell(nOctaves1,nLayers,nOctaves2,nLayers);
confidence = zeros(nOctaves1,nLayers,nOctaves2,nLayers);
if scl_flag
    for octave2=1:nOctaves2
        for octave1=1:nOctaves1
            for layer2=1:nLayers
                for layer1=1:nLayers
    [matches{octave1,layer1,octave2,layer2},...
        confidence(octave1,layer1,octave2,layer2)] = Match_Keypoint(...
        descriptors_1{octave1,layer1},descriptors_2{octave2,layer2},Error,K);
                end
            end
        end
    end
else
    for octave=1:min(nOctaves1,nOctaves2)
        for layer2=1:nLayers
            for layer1=1:nLayers
    [matches{octave,layer1,octave,layer2},...
        confidence(octave,layer1,octave,layer2)] = Match_Keypoint(...
        descriptors_1{octave,layer1},descriptors_2{octave,layer2},Error,K);
            end
        end
    end
end
clear descriptors_1 descriptors_2

%% Optimizing
cor1 = cell(nOctaves1,nOctaves2);
cor2 = cell(nOctaves1,nOctaves2);
Confidence = zeros(nOctaves1,nOctaves2);
for octave1=1:nOctaves1
    for octave2=1:nOctaves2
        Matches = [];
        for layer1=1:nLayers
            for layer2=1:nLayers
                Matches = [Matches; matches{octave1,layer1,octave2,layer2}];
            end
        end
        if size(Matches,1)>20
            Matches = Matches(:,[3:4,1:2,5,8:9,6:7,10]);  % Switch kps and kps_t
            [~,index1,~] = unique(Matches(:,1:2),'rows');
            Matches = Matches(index1,:);
            [~,index2,~] = unique(Matches(:,6:7),'rows');
            Matches = Matches(index2,:);
        end
        if size(Matches,1)>20
            NCMs = zeros(K,1); indexPairs = cell(K,1);
            for k = 1:K
                [~,~,indexPairs{k}] = Outlier_Removal(Matches(:,1:5),Matches(:,6:10),Error);
                NCMs(k) = sum(indexPairs{k});
            end
            [Confidence(octave1,octave2),maxIdx] = max(NCMs);
            indexPairs = indexPairs{maxIdx};
            cor1{octave1,octave2} = Matches(indexPairs,1:5);
            cor2{octave1,octave2} = Matches(indexPairs,6:10);
        end
    end
end
[max_O1,max_O2] = find(Confidence==max(max(Confidence)));
cor1 = cor1{max_O1,max_O2}; cor2 = cor2{max_O1,max_O2};