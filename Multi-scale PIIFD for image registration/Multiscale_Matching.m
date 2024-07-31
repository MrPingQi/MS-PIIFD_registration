function [cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves_1,nOctaves_2,nLayers,scl_flag)
%% Matching
matches = cell(nOctaves_1,nLayers,nOctaves_2,nLayers);
confidence = zeros(nOctaves_1,nLayers,nOctaves_2,nLayers);

if scl_flag
    for Octave2=1:nOctaves_2
        for Octave1=1:nOctaves_1
            for Layer2=1:nLayers
                for Layer1=1:nLayers
    [matches{Octave1,Layer1,Octave2,Layer2},...
        confidence(Octave1,Layer1,Octave2,Layer2)] = Match_Keypoints_BF(...
        descriptors_1{Octave1,Layer1},descriptors_2{Octave2,Layer2});
                end
            end
        end
    end
else
    for Octave=1:min(nOctaves_1,nOctaves_2)
        for Layer2=1:nLayers
            for Layer1=1:nLayers
    [matches{Octave,Layer1,Octave,Layer2},...
        confidence(Octave,Layer1,Octave,Layer2)] = Match_Keypoints_BF(...
        descriptors_1{Octave,Layer1},descriptors_2{Octave,Layer2});
            end
        end
    end
end
clear descriptors_1 descriptors_2;

%% Preferring
Confidence = zeros(nOctaves_1,nOctaves_2);
cor1 = cell(nOctaves_1,nOctaves_2);
cor2 = cell(nOctaves_1,nOctaves_2);
for Octave1=1:nOctaves_1
    for Octave2=1:nOctaves_2
        Matches = [];
        for Layer1=1:nLayers
            for Layer2=1:nLayers
                Matches = [Matches; matches{Octave1,Layer1,Octave2,Layer2}];
            end
        end
        if size(Matches,1)>0
            [~,index1,~] = unique(Matches(:,1:2),'rows');
            Matches = Matches(index1,:);
            [~,index2,~] = unique(Matches(:,6:7),'rows');
            Matches = Matches(index2,:);
            cor1{Octave1,Octave2} = Matches(:,1:5);
            cor2{Octave1,Octave2} = Matches(:,6:10);
%             [cor1{Octave1,Octave2},cor2{Octave1,Octave2}] = ...
%                 Outlier_Removal_PIIFD(cor1{Octave1,Octave2},cor2{Octave1,Octave2},0.2,0.85,0.1);
            [cor1{Octave1,Octave2},cor2{Octave1,Octave2},~] = ...
                Outlier_Removal_FSC(cor1{Octave1,Octave2},cor2{Octave1,Octave2},5);
            Confidence(Octave1,Octave2) = size(cor1{Octave1,Octave2},1);
        else
            Confidence(Octave1,Octave2) = 0;
        end
    end
end
[max_O1,max_O2] = find(Confidence==max(max(Confidence)));
cor1 = cor1{max_O1,max_O2}; cor2 = cor2{max_O1,max_O2};
[cor1,cor2,~] = Outlier_Removal_FSC(cor1,cor2,5);
% [cor1,cor2] = Outlier_Removal_PIIFD(cor1,cor2,0.2,0.85,0.1);