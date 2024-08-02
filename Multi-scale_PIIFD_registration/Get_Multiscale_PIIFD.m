%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptors = Get_Multiscale_PIIFD(I,kps,...
    nOctaves,nLayers,G_resize,G_sigma,scale,NBS,NBO,int_flag,rot_flag)

sig = Get_Gaussian_Scale(G_sigma,nLayers);
descriptors = cell(nOctaves,nLayers); I_t = [];
for octave=1:nOctaves
    kps_t = round(kps(:,1:2)./G_resize^(octave-1));
    [~,index,~] = unique(kps_t,'rows');
    for layer=1:nLayers
        I_t = Gaussian_Scaling(I, I_t, octave, layer, G_resize, sig(layer));
        descriptors{octave,layer} = PIIFD_Descriptor(I_t, ...
            [kps_t(index,1:2),kps(index,1:2)], scale, NBS, NBO, int_flag, rot_flag);
    end
end


function sig = Get_Gaussian_Scale(sigma,numLayer)
sig = zeros(1,numLayer);
sig(1) = sigma;
k = 2^(1.0/(numLayer-1));
for i = 2:numLayer
    sig_previous = k^(i-2)*sigma;
    sig_current = k*sig_previous;
    sig(i) = sqrt(sig_current^2-sig_previous^2);
end


function I_t = Gaussian_Scaling(I,I_t,Octave,Layer,G_resize,sig)
if(Octave==1 && Layer==1)
    I_t = I;
elseif(Layer==1)
    I_t = imresize(I,1/G_resize^(Octave-1),'bilinear');
else
    W = round(2*sig);
    W = 2*W+1;
    w = fspecial('gaussian',[W,W],sig);
    I_t = imfilter(I_t,w,'replicate');
end