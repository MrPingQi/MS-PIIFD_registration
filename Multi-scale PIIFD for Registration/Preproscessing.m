function [I_o,I] = Preproscessing(image,resample)

%% Data fitting
if size(image,3)==2
    I_o=image(:,:,2);
elseif size(image,3)==1 || size(image,3)==3
    I_o=image;
elseif size(image,3)>3 && size(image,3)<61
%     [coeff,score,latent] = pca(reshape(I1_o,));
%     I1 = score(1:3);
    I_o(:,:,1)=image(:,:,4);
    I_o(:,:,2)=image(:,:,3);
    I_o(:,:,3)=image(:,:,2);
else
%     [coeff,score,latent] = pca(I1_o);
%     I1 = score(1:3);
    I_o(:,:,1)=image(:,:,121);
    I_o(:,:,2)=image(:,:,54);
    I_o(:,:,3)=image(:,:,40);
end

%% Data normalization
I_o=im2double(I_o);
I_o=I_o/max(I_o(:));
if size(I_o,3)>1
    I = rgb2gray(I_o);
else
    I = I_o;
end
I=I/mean(I(:))/2;

%% Resampling
I=imresize(I,resample,'bilinear');