%function [upper_env, central_env, lower_env] = env_find(fIn)
clc; clear all; close all;
fIn='C:\Users\uarspl\Desktop\Output2_NSF_walk\png_img\NW1.png';
img_matrix = im2double(rgb2gray(imread(fIn)));
img_matrix(img_matrix<0.0589) = 0;
total_pow = sum(img_matrix);
central_lim = 0.52*total_pow;
%low pass filter
[b,a]=butter(2,10/(250/2));
central_env = zeros(1,size(img_matrix,2));
Sum = 0;

%% Central envelope
for t = 1:size(img_matrix,2)  
    for v = size(img_matrix,1):-1:1
        Sum = Sum + img_matrix(v,t);
        if (Sum > central_lim(t))
         
                Sum = 0;
                break
           
        end
    end
    central_env(t) = v;
end
%central_env=filtfilt(b,a,central_env);
%% Central envelope2
for t = 1:size(img_matrix,2)  
    for v = 1:1:size(img_matrix,1)
        Sum = Sum + img_matrix(v,t);
        if (Sum > central_lim(t))
         
                Sum = 0;
                break
           
        end
    end
    central_env2(t) = v;
end

two_cntrl=zeros(2,length(central_env2));
two_cntrl(1,:)=central_env;
two_cntrl(2,:)=central_env2;
mean_2=mean(two_cntrl);
%figure; plot(-1*(central_env),'m','LineWidth',2);hold on; plot(-1*(central_env2),'y','LineWidth',2); hold on; plot(-1*(mean_2),'c','LineWidth',2);
new_env=zeros(1,length(mean_2));

for idx=1:length(mean_2)
    if mean_2(idx)>central_env(idx)&& mean_2(idx)<mean_2(1)
        new_env(idx)=central_env(idx);
     
    elseif  mean_2(idx)>central_env(idx)&& mean_2(idx)>mean_2(1)
        new_env(idx)=central_env2(idx);
    end
end
new_env(1)=central_env(1);
new_env=filtfilt(b,a,new_env);
figure; imshow(imread(fIn));hold on; plot(1*(new_env),'m','LineWidth',2);

%function vel = pix_to_vel(pix)
pix=new_env;
pix = squeeze(squeeze(pix));
crop_height = 784;
prf = 3000;
orig_im_height = 784;
crop_resize = 784;
limits = linspace(-prf/2, prf/2, prf+1);
freq_per_pix = length(limits)/orig_im_height;
freq = limits(floor(pix /crop_resize*crop_height / crop_height*orig_im_height * freq_per_pix)+1);
velocity = -1*(3*10^8*freq/2/(77*10^9));
time_axis=linspace(0,15,length(velocity));
figure;plot(time_axis,(velocity),'m','LineWidth',2);
xlabel('Time (Sec)');ylabel('Torso velocity (M/S)');


