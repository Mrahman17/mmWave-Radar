clc; clear; close all; warning off;

dataasl = {'radar_06/','radar_07/','radar_08/'};
datadaily = {'Front/','Corner/','Side/'};

asl_data = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Last 10 ASL/';
daily_data = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Last 10 Daily/';

fps = 25;
% starting_bins = [1 150 100 150];
% ending_bins = [201 180 201 201];

starting_bins = [1024 1 1024];
ending_bins = [2048 2048 1536];
for k = 1:1%length(dataasl)
        ASL_DIR = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Final 77 ASL/';
%         ASL_DIR = strcat(asl_data,dataasl{k});
        pattern = strcat(ASL_DIR, '*.mat');    % file pattern
        files = dir(pattern);
        I_MAX = numel(files); % # of files in "files"
        
        daily_data_dir = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Final 77 Daily/';
%         daily_data_dir = strcat(daily_data,datadaily{k});
        pattern = strcat(daily_data_dir , '*.mat');    % file pattern
        files1 = dir(pattern);
        J_MAX = numel(files1); % # of files in "files"
        
        for m=1:length(starting_bins)
                starting_bin = starting_bins(m);
                ending_bin = ending_bins(m);
                
                for i = 1:I_MAX
                        msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX+J_MAX),...
                                ' | ', int2str(m), ' of ', int2str(length(starting_bins)),...
                                ' | ', int2str(k), ' of ', int2str(length(dataasl))]);   % loading message
                        disp(msg);
                        
                        fName = files(i).name;
                        [foo1, name, foo2] = fileparts(fName);
                        fIn = strcat(ASL_DIR, fName);
                        [ASL_betabar(i), ASL_beta_mean(i),magnitude_func_ASL{1,i}] = Frac_Comp_from_PSD(fIn,fps,starting_bin,ending_bin);
                        
                end
                for j=1:J_MAX
                        msg = strcat(['Processing file ', int2str(j+i), ' of ', int2str(I_MAX+J_MAX),...
                                ' | ', int2str(m), ' of ', int2str(length(starting_bins)),...
                                ' | ', int2str(k), ' of ', int2str(length(datadaily))]);
                        disp(msg);

                        fName1 = files1(j).name;
                        [foo1, name, foo2] = fileparts(fName1);
                        fIn1 = strcat(daily_data_dir, fName1);
                        [dailybetabar(j), daily_beta_mean(j), magnitude_func_daily{1,j}] = Frac_Comp_from_PSD(fIn1,fps,starting_bin,ending_bin);


                end
                
%                 savepath = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Fractal Complexity Results/Xethru RD Map Results/Xethru RD_Video_ASLvsDaily_',data{k}(1:end-1),'_',num2str(starting_bin),'x',num2str(ending_bin),'.mat');
                savepath = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Fractal Complexity Results/Final 77/77final_RD_aslvsdaily_',num2str(starting_bin),'x',num2str(ending_bin),'.mat');
%                 savepath = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Fractal Complexity Results/Last 10/',datadaily{k}(1:end-1),'_',num2str(starting_bin),'x',num2str(ending_bin),'.mat');
                save(savepath, 'ASL_betabar','ASL_beta_mean','dailybetabar','daily_beta_mean','magnitude_func_ASL','magnitude_func_daily');
%                 save(savepath, 'ASL_betabar','ASL_beta_mean','magnitude_func_ASL');
                
        end
end    