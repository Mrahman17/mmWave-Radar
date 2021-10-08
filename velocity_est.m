clc; clear all; close all;
fIn='C:\Users\uarspl\Desktop\77ghz_data\output_DR_Martelli\full_fig_4.png';
im=jet2gray(fIn);
im2=(im(:,:,1));
figure; imshow(im2)
%im2=im2(5:780,:);
for ii=1:size(im2,2)
    track_vel(ii)=max(max(im2(:,ii)));
end
[b,a]=butter(2,30/(500/2));
track_vel=filtfilt(b,a,double(track_vel));

figure; plot(track_vel)
figure; imshow(im2); hold on; plot((flipud(track_vel+200)),'m','LineWidth',2);
