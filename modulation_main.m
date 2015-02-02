clear;
addpath('spams-matlab\build');
global CORENUM
CORENUM = 8;
%Initialize Matlab Parallel Computing Environment
if isempty(gcp('nocreate'))
    parpool('local',CORENUM);
else
    disp('Parallel computing mode already initialized'); 
end
datadir = 'textures_for_v1_v2/sythe_data_test_1';

layer = 5;
imgchannel = 1;
patchsz = [11,5,3,3,3];
conv_stride = [4,1,1,1,1];
conv_padding = [0,2,1,1,1];
nbases = [64,192,384,256,256];
ratio = [3,3,1,1,3];
pool_stride = [2,2,1,1,2];
skip_layer = [false,false,false,false,false];
MinImSize = 227;

param = cell(1,layer);
for k = 1:layer
    info.patchsz = patchsz(k);
    info.conv_stride = conv_stride(k);
    info.conv_padding = conv_padding(k);
    info.nbases = nbases(k);
    info.ratio = ratio(k);
    info.pool_stride = pool_stride(k);
    info.scparam.K = info.nbases;
    if k==1
        info.datadir = datadir;
    else
        info.datadir = param{k-1}.Crespdir;
    end
    info.Crespdir = ['Resp1/C' num2str(k)];
    info.Afile = ['Results/S' num2str(k) 'bases' ...
        '_nBases_' num2str(info.nbases) '_patchsz_' num2str(info.patchsz) '.mat'];
    param{k} = info;
end


for k = 1:layer
    if ~skip_layer(k)
        fprintf('\n-----------------------------------\n');
        fprintf(['Calculating C' num2str(k) '  layer response...\n']);
        fprintf('-----------------------------------\n');
        load(param{k}.Afile);
        if k==1
            layerC1(param{k}.datadir,param{k}.Crespdir,A,param{k}.conv_stride,param{k}.conv_padding,param{k}.pool_stride,param{k}.ratio,param{k}.patchsz,MinImSize);%param{k}.scparam);
        else
            layerC(param{k}.datadir,param{k}.Crespdir,A,param{k}.conv_stride,param{k}.conv_padding,param{k}.pool_stride,param{k}.ratio,param{k}.patchsz);%param{k}.scparam);
        end
    end
end
delete(gcp('nocreate'));