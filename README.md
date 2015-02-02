#Sparse HMAX for modulation difference in V1 and V2
1. learning phase using `main` (learning bases with sparse coding, C's responses are just plain convolution)
2. compute modulation using `modulation-main`, same with the above procesure
3. compute statistics using `stat`. The neurons with zero firing rate in both scenarios are excluded, but in the normalization phase of computing distribution, this has not been considered. Need to improve

