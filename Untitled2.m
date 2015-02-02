%datadir = 'C:\Users\wangyl\Desktop\newcifar10\cifar-10-batches-mat';
%cd datadir
count = 1;
for k = 1:5
    dta = fullfile(['data_batch_' num2str(k) '.mat']);
    load dta data
    s = permute(reshape(data',[32,32,3,10000]),[2,1,3,4]);
    for j=1:10000
        name = sprintf('img_%05d.jpg',count);
        imwrite(s(:,:,:,j),fullfile('data\cifar10',name),'jpg');
        count = count + 1;
    end
end