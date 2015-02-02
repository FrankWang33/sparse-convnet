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
datadir = 'data';

layer = 5;
imgchannel = 1;
samplesz = [200000,200000,200000,200000,200000];
patchsz = [11,5,3,3,3];
conv_stride = [4,1,1,1,1];
conv_padding = [0,2,1,1,1];
nbases = [64,192,384,256,256];
ratio = [3,3,1,1,3];
pool_stride = [2,2,1,1,2];
skip_layer = [false,false,false,false,false,false,false,false,false,false];
MinImSize = 227;

scparam.mode=0; % type of sparse coding problem solved
scparam.modeD=0; % length of each basis <=1
scparam.lambda=0.15;
scparam.numThreads=-1; % number of threads
scparam.batchsize=100;
scparam.verbose=0; % 0 or 1
scparam.iter=15000;

param = cell(1,layer);
for k = 1:layer
    info.samplesz = samplesz(k);
    info.patchsz = patchsz(k);
    info.conv_stride = conv_stride(k);
    info.conv_padding = conv_padding(k);
    info.nbases = nbases(k);
    info.ratio = ratio(k);
    info.pool_stride = pool_stride(k);
    info.scparam = scparam;
    info.scparam.K = info.nbases;
    if k==1
        info.datadir = datadir;
    else
        info.datadir = param{k-1}.Crespdir;
    end
    info.Crespdir = ['C' num2str(k)];
    info.Afile = ['Results/S' num2str(k) 'bases' ...
        '_nBases_' num2str(info.nbases) '_patchsz_' num2str(info.patchsz) '.mat'];
    param{k} = info;
end

for k = 1:layer
    if skip_layer(2*k-1)
        load(param{k}.Afile,'A');
    else
        fprintf('-----------------------------------\n\n');
        fprintf(['Learning S' num2str(k) 'bases...\n']);
        fprintf('-----------------------------------\n');

        fprintf('Sampling & Normalizing data...\n')
        tic;
        if k==1
            X = sampleimages(param{k}.datadir,param{k}.samplesz,param{k}.patchsz,imgchannel);
        else
            X = sample3D(param{k}.datadir,param{k}.samplesz,param{k}.patchsz,param{k-1}.nbases);
        end
        toc;
        fprintf('Starting SC...\n')
        tic;
        A = mexTrainDL(X,param{k}.scparam);
        fprintf('Starting Lasso...\n') 
        alpha=mexLasso(X,A,param{k}.scparam);
        toc;
        fprintf('sparsity is %6.4f\n', full(sum(alpha(:)~=0)/length(alpha(:))));
        save(param{k}.Afile,'A'); 
    end
    
    if ~skip_layer(2*k)
        fprintf('\n-----------------------------------\n');
        fprintf(['Calculating C' num2str(k) '  layer response...\n']);
        fprintf('-----------------------------------\n');
        load(param{k}.Afile);
        tic;
        if k==1
            layerC1(param{k}.datadir,param{k}.Crespdir,A,param{k}.conv_stride,param{k}.conv_padding,param{k}.pool_stride,param{k}.ratio,param{k}.patchsz,MinImSize);%param{k}.scparam);
        else
            layerC(param{k}.datadir,param{k}.Crespdir,A,param{k}.conv_stride,param{k}.conv_padding,param{k}.pool_stride,param{k}.ratio,param{k}.patchsz);%param{k}.scparam);
        end
        toc;
    end
end
delete(gcp('nocreate'));
        

