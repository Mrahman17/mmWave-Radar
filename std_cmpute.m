clc; clear; close all;

datapath = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Fractal Complexity Results/Last 77/*.mat');

files = dir(datapath);
imax = numel(files);

for i=1:imax
   
        fname = fullfile(files(i).folder,files(i).name);
        load(fname);
        aslstd(i) = std(ASL_beta_mean);
        dailystd(i) = std(daily_beta_mean);
        
end



