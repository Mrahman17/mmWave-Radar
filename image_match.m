clc; clear all; close all;
% Read two imges
A=('E:\Mahbub\Villanova-mbgan\towards.png'); 
B=('wlk_Cane\MBGAN\110.png');

% Find Envelop
[UpA,~,DwnA]=env_find(A);
[UpB,~,DwnB]=env_find(B);

figure; imshow(rgb2gray(imread(A)));hold on; plot(UpA); hold off;
figure; imshow(rgb2gray(imread(B)));hold on; plot(UpB);

% DIscrete Frechet Distance, cm
[cm, cSq] = DiscreteFrechetDist(UpA,UpB);
% Dynamic Time-Wrapping distance
dist = dtw(UpA,UpB);

% Structural similarity (SSIM) index
test_img=rgb2gray(imread(B));
ref_img =rgb2gray(imread(A));
ssimval = ssim(test_img,ref_img);

% For 2 group of images, we can find pearson correlation and canonical
% correlation. We need to convert the whole image into a signle Row
% vectors, in this way form a matrix for each group of images. then find
% their correlations
R = corrcoef(group1,group2); % Pearson correlations. look into diagonal values. 
[A,B,r] = canoncorr(X,Y); % Cannonical correlations. A,B coefecient, r is the correlations.



