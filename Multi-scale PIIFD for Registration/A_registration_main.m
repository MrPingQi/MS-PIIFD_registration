clear; close all; clc;
if isempty(gcp('nocreate'))
    parpool(maxNumCompThreads);
end
%% Make fileholder for save images
if (exist('save_image','dir')==0) % 如果文件夹不存在
    mkdir('save_image');
end

%% Define the constants
G_resize = 3;   % 高斯金字塔的降采样单元，默认:2
G_sigma = 1.6;  % 高斯金字塔的模糊单元，默认:1.6
numLayers = 4;  % 高斯金字塔每组层数，默认:4
sigma = 20;     % Harris 局部加权高斯核标准差上限
thresh = 50;    % Harris 角点响应判别阈值
radius = 15;    % Harris 局部非极大值抑制窗半径
N = 1000;       % 特征点数量择优阈值
trans_form = 'similarity';  % 变换模型：'similarity','affine','perspecive'

%% Read images
[image_1, image_2] = Readimage;
% image_1=imresize(image_1,3,'bilinear');

%% Image preproscessing
resample1 = 1; resample2 = 1;
[I1_o,I1] = Preproscessing(image_1,resample1);  % I1:参考图像
[I2_o,I2] = Preproscessing(image_2,resample2);  % I2:待配准图像
% figure; subplot(121),imshow(I1,[]); subplot(122),imshow(I2,[]);

%% The number of groups in Gauss Pyramid
numOctaves_1 = 3;
numOctaves_2 = 3;
sig = Get_Gaussian_Scale(G_sigma,numLayers);
ratio = sqrt(size(I1,1)*size(I1,2)/(size(I2,1)*size(I2,2)));

fprintf('\n开始图像配准，请耐心等待\n\n'); tic

%% Harris Corner Detection
p1 = Detect_Harris_Conner(I1,sigma,thresh,floor(radius*ratio),N,numOctaves_1,G_resize,1);
    str = ['已完成参考图像特征点检测，用时',num2str(toc),'s\n']; fprintf(str); tic
p2 = Detect_Harris_Conner(I2,sigma,thresh,radius,N,numOctaves_2,G_resize,1);
    str = ['已完成待配准图像特征点检测，用时',num2str(toc),'s\n\n']; fprintf(str); tic

%% Create PIIFD Descriptor
descriptors_1 = Get_Multiscale_PIIFD(I1,p1,numOctaves_1,numLayers,G_resize,sig);
    str = ['已完成参考图像描述符建立，用时',num2str(toc),'s\n']; fprintf(str); tic
descriptors_2 = Get_Multiscale_PIIFD(I2,p2,numOctaves_2,numLayers,G_resize,sig);
    str = ['已完成待配准图像描述符建立，用时',num2str(toc),'s\n\n']; fprintf(str); tic

%% Matching and Transforming
[location1,location2] = Match_Keypoint(I1,I2,descriptors_1,descriptors_2,numOctaves_1,numOctaves_2,numLayers,0);
matchment = Showmatch(I1_o,I2_o,location1/resample1,location2/resample2);
[H,rmse,cor2,cor1] = FSC(location2/resample2,location1/resample1,trans_form,2);
% matchment1 = Showmatch(I1_o,I2_o,cor1,cor2);
[I1_c,I2_c,I3,I4] = Transformation(I1_o,I2_o,double(H));
    str = ['已完成图像变换，用时',num2str(toc),'s\n\n']; fprintf(str);

figure; imshow(I3,[]); title('Fusion Form');
figure; imshow(I4,[]); title('Checkerboard Form');

%% Save images
Date = datestr(now,'yyyy-mm-dd_HH-MM-SS__'); tic
str=['.\save_image\',Date,'1 Matching Result','.jpg']; saveas(matchment,str);
str=['.\save_image\',Date,'2 Reference Image','.jpg']; imwrite(I1_c,str);
str=['.\save_image\',Date,'3 Transformed Image','.jpg']; imwrite(I2_c,str);
str=['.\save_image\',Date,'4 Fusion of results','.jpg']; imwrite(I3,str);
str=['.\save_image\',Date,'5 Checkerboard of results','.jpg']; imwrite(I4,str);
str = ['配准结果已经保存在程序根目录下的save_image文件夹中，\n用时',num2str(toc),'s\n']; fprintf(str);
% end
