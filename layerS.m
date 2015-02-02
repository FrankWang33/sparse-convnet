function S=layerS(X,bases,patchsz,scparam)
%% Concatinate the features
[row,col,num_bases]=size(X);
descrs = zeros(patchsz^2*num_bases,(row-patchsz+1)*(col-patchsz+1),'single');
for i=1:num_bases
    descrs((i-1)*patchsz^2+1: i*patchsz^2, :) = im2col(X(:,:,i),[patchsz,patchsz],'sliding');
end

%% Normalize the features
descrs=patch_normalize(descrs);

%% Project to the principal components space 

%% calculate S1 map

S = mexLasso(descrs,bases,scparam)';
sparsity_S = sum(S(:)~=0)/length(S(:));
%fprintf('sparsity_S = %g\n', full(sparsity_S));    

% convert back to 3D arrays
S=reshape(single(full(S)),row-patchsz+1,col-patchsz+1,size(bases,2));
