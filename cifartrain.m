% current folder is MySHMAX
clear;
filelist = dir(fullfile('respdir/cifar10/C3','*.mat'));
feature = zeros(4*4*64,length(filelist));
load('data/train_label.mat');
label = double(label);
parfor k=1:length(filelist)
    name = fullfile('respdir/cifar10/C3',filelist(k).name);
    temp=load(name,'C');
    feature(:,k) = reshape(temp.C,[],1);
end

conf.biasMultiplier=1;
conf.C=10;
svm = train(label, sparse(feature)',  ...
    sprintf(' -s 3 -B %f -c %f', ...
    conf.biasMultiplier, conf.C)) ;
 w = svm.w';
model.b = conf.biasMultiplier * w(end, :) ;
model.w = w(1:end-1, :) ;
scores = model.w' * feature + model.b' * ones(1,size(feature,2)) ;
[drop, imageEstClass] = max(scores, [], 1) ;
imageEstClass = imageEstClass';

clabel = 0:1:9;
acc = zeros(length(clabel), 1);
%%    
for jj = 1 : length(clabel),
    c = clabel(jj);
    idx = find(label == c);
    curr_pred_label = imageEstClass(idx);
    curr_gnd_label = label(idx);    
    acc(jj) = length(find(curr_pred_label == curr_gnd_label))/length(idx);
end;