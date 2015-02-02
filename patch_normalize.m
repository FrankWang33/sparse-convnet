function [patch_arr] = patch_normalize(X)
% each column is a patch data
% X=bsxfun(@minus, X, mean(X,1));
% varX=sum(X.^2,1)/(size(X,1)-1);
% ind= varX>1e-6;
% patch_arr=zeros(size(X),'single');
% patch_arr(:,ind) = bsxfun(@rdivide, X(:,ind) , sqrt(varX(ind)) );

X = bsxfun(@minus, X, mean(X,1));
patch_arr = bsxfun(@rdivide, X, sqrt(var(X,[],1)+10));
