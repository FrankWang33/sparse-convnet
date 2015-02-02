function C=Smap_pooling(map, ratio_row,ratio_col,row_rest,col_rest,poolmethod)
[row,col,num_bases]=size(map);

%% trim the borders
map(row-(row_rest-round(row_rest/2))+1:row,:,:)=[];
map(1:round(row_rest/2),:,:)=[];
map(:,col-(col_rest-round(col_rest/2))+1:col,:)=[];
map(:,1:round(col_rest/2),:)=[];
% evaluate the size again
[row,col,num_bases]=size(map);
% check if the size of map is divisive by the block.
if mod(row,ratio_row) || mod(col,ratio_col)
    error('Trimming is incorrect')
end
    
%% use blkproc 
% % PS: this method is about 10 times slower than im2col
% if strcmp(poolmethod,'max')
%     pmax = @(x) max(x(:));
% elseif strcmp(poolmethod,'avg')
%     pmax = @(x) mean(x(:));
% else
%     error('Pooling method is not specified.')
% end
% C=zeros(row/ratio_row,col/ratio_col,num_bases,'single');
% for i=1:num_bases
%     % down sampling with max pooling
%     C(:,:,i) = blkproc(map(:,:,i),[ratio_row ratio_col],pmax);
% end

%% use im2col
map2D=reshape(map,row,col*num_bases);
if strcmp(poolmethod,'max')
    temp=max( im2col(map2D,[ratio_row,ratio_col],'distinct'), [], 1 );
elseif strcmp(poolmethod,'avg')
    temp=mean( im2col(map2D,[ratio_row,ratio_col],'distinct'),1 );
else
    error('Pooling method is not specified.')
end
C=reshape(temp,row/ratio_row,col/ratio_col,num_bases);

