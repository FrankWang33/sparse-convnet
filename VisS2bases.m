function B=VisS2bases(A1,A2,patchsz1,patchsz2,r1)
% Visualize the S3 bases.
% Main idea: transform the S3 bases to the original image space using weighted sum 
% of S2 bases, and in the sequal the weighted sum of S1 bases.
% Steps:
% 1. For each S2 unit, its RF is defined directly on C1 maps, while each C1 unit corresponds to a r1 x r1 patch on S1 units. 
%    Since we assume square patches, in what follows, we only describe the side length, that is, we say patch size is r1 . 
%    We expand each S2 basis to patchsz2*r1 on S1 maps.
% 2. Convolve the resulted patches with A1 bases (size patchsz1) and obtain patches on image layer, 
%    the size of which becomes patchsz2*r1+patchsz1-1 
% Finally sum all patches on image layer together.

[L2,nbases2]=size(A2);
[L1,nbases1]=size(A1);
if L2~=nbases1*patchsz2^2
    error('The dimensions of bases are inconsistent!')
end
expmat = ones(r1);

RFsz = r1*patchsz2+patchsz1-1;
B=zeros(RFsz^2,nbases2,'single');

for i=1:nbases2
    % Step 1
    basis2=reshape(A2(:,i),patchsz2^2,nbases1);
    for k=1:nbases1        
        temp=reshape(basis2(:,k),patchsz2,patchsz2);
        expand=kron(temp,expmat);
        % step 2
        basis1=reshape(A1(:,k),patchsz1,patchsz1);
        map=conv2(expand,basis1,'full');
        B(:,i)=B(:,i)+map(:);
    end    
end

