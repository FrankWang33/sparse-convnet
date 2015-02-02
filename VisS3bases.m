function B=VisS3bases(A1,A2,A3,patchsz1,patchsz2,patchsz3,r1,r2)
% Visualize the S3 bases.
% Main idea: transform the S3 bases to the original image space using weighted sum 
% of S2 bases, and in the sequal the weighted sum of S1 bases.
% Steps:
% 1. For each S3 unit, its RF is defined directly on C2 maps, while each C2 unit corresponds to a r2 x r2 patch on S2 units. 
%    Since we assume square patches, in what follows, we only describe the side length, that is, we say patch size is r2 . 
%    We expand each S3 basis to patchsz3*r2 on S2 maps.
% 2. Convolve the resulted patches with A2 bases (size patchsz2) and obtain patches on C1 maps, 
%    the size of which becomes patchsz3*r2+patchsz2-1 
% 3. Expand the resulted patches to r1*(patchsz3*r2+patchsz2-1) on S1 maps
% 4. Convolve the resulted patches with A1 bases (size patchsz1) and obtain patches on images, 
%    the size of which becomes r1*(patchsz3*r2+patchsz2-1)+patchsz1-1

[L3,nbases3]=size(A3);
[L2,nbases2]=size(A2);
[L1,nbases1]=size(A1);
if L3~=nbases2*patchsz3^2 || L2~=nbases1*patchsz2^2
    error('The dimensions of bases are inconsistent!')
end
expmat2 = ones(r2);
expmat1 = ones(r1);

RFsz = r1*(patchsz3*r2+patchsz2-1)+patchsz1-1;
B=zeros(RFsz^2,nbases3,'single');

for i=1:nbases3 
    % Step 1: For each S3 bases, obtain nbases2 patches on S2 maps
    basis3 = reshape(A3(:,i),patchsz3^2,nbases2);
    for j=1:nbases2        
        temp = reshape(basis3(:,j),patchsz3,patchsz3);
        expand2 = kron(temp,expmat2); % size: patchsz3*r2
        % step 2: Convolve the resulted patches with A2 bases 
        basis2 = reshape(A2(:,j),patchsz2^2,nbases1);
        for k=1:nbases1
            temp = reshape(basis2(:,k),patchsz2,patchsz2);
            map2 = conv2(expand2,temp,'full'); % size: patchsz3*r2+patchsz2-1 
            % step 3: Expand patches on S1 map
            expand1 = kron(map2,expmat1); % size: r1*(patchsz3*r2+patchsz2-1)
            % step 4: Convolve the resulted patches with A1 bases
            map1 = conv2(expand1,reshape(A1(:,k),patchsz1,patchsz1),'full');
            B(:,i)=B(:,i)+map1(:);
        end
    end
    
    fprintf('Visualizing S3 basis #%d / %d\n',i,nbases3);
end


