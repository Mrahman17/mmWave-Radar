clc; clear; close all;


subject = '15 jan emin';

path = ['/mnt/HDD01/rspl-admin/DATASETS/Fall Sequential/Outputs/' subject '/microDoppler/*.png'];

files = dir(path);
imax = numel(files);
% width = size(imread(fullfile(files(1).folder, files(1).name)),2);
% upper_env = zeros(imax,width);
% central_env = zeros(imax,width);
% lower_env = zeros(imax,width);
for i = 1:imax
   msg = strcat(['Processing file ', int2str(i), ' of ', int2str(imax)]);   % loading message
   disp(msg);
   fname = fullfile(files(i).folder, files(i).name);
   savename = [files(i).folder(1:end-13) '/envelopes/' files(i).name(1:end-4) '.txt'];
   im = imread(fname);
   [up,cent,low] = env_find(fname);
   
   final_env(1,:) = size(im,1) - up; % envelopes come reverse in y axis
   final_env(2,:) = size(im,1) - cent;
   final_env(3,:) = size(im,1) - low;
   final_env(final_env>750) = min(final_env(1,:));
   final_env(final_env<100) = max(final_env(3,:));
   
   margin = final_env(1,:)-final_env(3,:);
   
   dlmwrite(savename, margin,'delimiter',' ');
   clear final_env
end

% outnames = {'Upper_env.txt', 'Central_env.txt', 'Lower_env.txt'};
% 
% upper_env(upper_env>750) = min(upper_env(:));
% lower_env(lower_env<100) = max(lower_env(:));
% 
% fOut1 = strcat(savepath, outnames{1});
% fOut2 = strcat(savepath, outnames{2});
% fOut3 = strcat(savepath, outnames{3});
% 
% dlmwrite(fOut1, upper_env,'delimiter',' ');
% dlmwrite(fOut2, central_env,'delimiter',' ');
% dlmwrite(fOut3, lower_env,'delimiter',' ');
% 
% readenvup = textread(fOut1);
% readenvcent = textread(fOut2);
% readenvlow = textread(fOut3);
% 
% hold on
% plot(final_env(1,:))
% plot(final_env(2,:))
% plot(final_env(3,:))

