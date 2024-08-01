%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
%   Beijing Key Laboratory of Fractional Signals and Systems,
%   Multi-Dimensional Signal and Information Processing Institute,
%   School of Information and Electronics, Beijing Institute of Technology.
% Contact: gao-pingqi@qq.com

% Multi-scale PIIFD for multi-source images matching/registration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc; clear;
addpath('functions')

%% Is there any obvious intensity difference (multi-modal)
int_flag = 1; % yes:1, no:0
%% Is there any obvious rotation difference
rot_flag = 1;
%% Is there any obvious scale difference
scl_flag = 1;
%% What spatial transformation model do you need at the end
trans_form = 'affine';  % similarity, affine, projective
%% What image pair output form do you need at the end
out_form = 'union';  % reference, union, inter
%% Do you want the visualization of registration results
Is_flag = 1;  % Visualization show
I3_flag = 1;  % Overlap form
I4_flag = 1;  % Mosaic form

%% Define the constants
G_resize = 2;    % 高斯金字塔降采样步长，默认:2;  Gaussian pyramid downsampling step, default: 2
nOctaves_1 = 3;  % 高斯金字塔组数，默认:3;  Number of groups in the Gaussian pyramid, default: 3
nOctaves_2 = 3;
G_sigma = 1.6;   % 高斯金字塔模糊步长，默认:1.6;  Gaussian pyramid blurring step, default: 1.6
nLayers = 4;     % 高斯金字塔每组层数，默认:4;  Number of layers per group in the Gaussian pyramid, default: 4
thresh = 50;     % Harris特征点响应判别阈值，默认:50;  Harris response threshold, default: 50 (Could be set to 0)
radius = 2;      % Harris局部非极大值抑制窗半径，默认:2;  Harris LNMS window radius, default: 2
Npoint = 5000;   % 特征点数量择优阈值，默认:2000/5000;  Feature point number threshold, default: 2000/5000
scale = 40;      % 描述符Patchsize，默认:42;  Descriptor patchsize, default: 40
NBS = 4;         % 描述符方格划分数，默认:4;  Descriptor grids division number, default: 4
NBO = 8;         % 描述符角度划分数，默认:8;  Descriptor angle division number, default: 8

%% Read images
[image_1,file1,~] = Readimage;
[image_2,file2,~] = Readimage;
% [image_1,~,~] = Readimage(file1);
% [image_2,~,~] = Readimage(file2);

%% Image preproscessing
resample1 = 1; resample2 = 1;
[I1_s,I1] = Preproscessing(image_1,resample1,[]);  % I1:参考图像; Reference image
[I2_s,I2] = Preproscessing(image_2,resample2,[]);  % I2:待配准图像; Sensed image
figure; subplot(121),imshow(I1_s); subplot(122),imshow(I2_s); drawnow
% figure; subplot(121),imshow(I1,[]); subplot(122),imshow(I2,[]); drawnow

%%
fprintf('\n开始图像配准，请耐心等待...\n Image registration starts, please be patient...\n\n');

%% Harris Keypoints Detection
ratio = sqrt(size(I1,1)*size(I1,2)/(size(I2,1)*size(I2,2)));
if ratio>=1
    r2 = radius; r1 = round(radius*ratio);
else
    r1 = radius; r2 = round(radius/ratio);
end
tic,keypoints_1 = Detect_Harris_Points(I1,6,thresh,r1,Npoint,nOctaves_1,G_resize,1);
    t=num2str(toc); fprintf(['已完成参考图像特征点检测，用时 ',t,'s\n']);
                    fprintf([' Done keypoints detection of reference image, time: ',t,'s\n']);
tic,keypoints_2 = Detect_Harris_Points(I2,6,thresh,r2,Npoint,nOctaves_2,G_resize,1);
    t=num2str(toc); fprintf(['已完成待配准图像特征点检测，用时 ',t,'s\n']);
                    fprintf([' Done keypoints detection of sensed image, time: ',t,'s\n\n']);

%% Create PIIFD Descriptor
tic,descriptors_1 = Get_Multiscale_PIIFD(I1,keypoints_1,...
    nOctaves_1,nLayers,G_resize,G_sigma,scale,NBS,NBO,int_flag,rot_flag);
    t=num2str(toc); fprintf(['已完成参考图像描述符建立，用时 ',t,'s\n']);
                    fprintf([' Done keypoints description of reference image, time: ',t,'s\n']);
tic,descriptors_2 = Get_Multiscale_PIIFD(I2,keypoints_2,...
    nOctaves_2,nLayers,G_resize,G_sigma,scale,NBS,NBO,int_flag,rot_flag);
    t=num2str(toc); fprintf(['已完成待配准图像描述符建立，用时 ',t,'s\n']);
                    fprintf([' Done keypoints description of sensed image, time: ',t,'s\n\n']);

%% Keypoints Matching
tic,[cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves_1,nOctaves_2,nLayers,scl_flag);
    t=num2str(toc); fprintf(['已完成特征点匹配，用时 ',t,'s\n']);
                    fprintf(['Done keypoints matching, time: ',t,'s\n\n']);
    matchment = Show_Matches(I1_s,I2_s,cor1/resample1,cor2/resample2,0);

%% Image Transformation
tic,[I1_r,I2_r,I1_rs,I2_rs,I3,I4,t_form,~] = Transformation(image_1,image_2,...
    cor1,cor2,trans_form,out_form,1,Is_flag,I3_flag,I4_flag);
    t=num2str(toc); fprintf(['已完成图像变换，用时 ',t,'s\n']);
                    fprintf([' Done images transformation，time: ',num2str(toc),'s\n\n']);
    figure,imshow(I3),title('Overlap Form');
    figure,imshow(I4),title('Mosaic Form');

%% Save Results
if (exist('save_image','dir')==0)  % 如果文件夹不存在创建一个; If the folder does not exist, create one.
    mkdir('save_image');
end
Date = datestr(now,'yyyy-mm-dd_HH-MM-SS__'); tic
corresponds = {cor1;cor2}; save(['.\save_image\',Date,'0 corresponds','.mat'],'corresponds','-v7.3');
saveas(matchment,['.\save_image\',Date,'0 Matching result','.jpg']);
imwrite(I1_r ,['.\save_image\',Date,'1 Reference image','.tif']);
imwrite(I2_r ,['.\save_image\',Date,'2 Registered image','.tif']);
imwrite(I1_rs,['.\save_image\',Date,'3 Reference image show','.jpg']);
imwrite(I2_rs,['.\save_image\',Date,'4 Registered image show','.jpg']);
imwrite(I3   ,['.\save_image\',Date,'5 Overlap of results','.jpg']);
imwrite(I4   ,['.\save_image\',Date,'6 Mosaic of results','.jpg']);
t=num2str(toc); fprintf(['配准结果已经保存在程序根目录下的save_image文件夹中，用时',t,'s\n']);
                fprintf([' Registration results are saved in the save_image folder, time: ',t,'s\n']);