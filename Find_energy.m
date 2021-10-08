
clc; clear; close all; warning off;
data = {'radar_06/', 'radar_07/', 'radar_08/'};

for k=1:1%3 
        DATA_DIR= strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD ASL/Xethru/',data{k}, 'Cut/');
%         DATA_DIR= strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD Daily/Xethru/Gray/',data{k});
%         DATA_DIR = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD ASL/Gray Cut/');
%         DATA_DIR = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD Daily/Gray/');
%         DATA_DIR = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/ASL video/';
        DATA_DIR = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Daily Video/';
        pattern = strcat(DATA_DIR, '*.avi');    % file pattern
        files = dir(pattern);
        I_MAX = numel(files); % # of files in "files"
        
%         daily_data_dir= '/mnt/HDD01/rspl-admin /ASL vs Daily Videos/RD Daily/Gray/';
%         savepathDaily = '/mnt/HDD01/rspl-admin /ASL vs Daily Videos/RD OF and PSD/New Daily 20 sec/';
%         pattern1 = strcat(daily_data_dir, '*.avi');    % file pattern
%         files1 = dir(pattern1);
%         J_MAX=numel(files1);
        
        
        % for j=1:J_MAX
        %     msg = strcat(['Processing file ', int2str(j), ' of ', int2str(J_MAX+I_MAX)]);   % loading message
        % %     waitbar(j/J_MAX, w, msg);
        %     disp(msg);
        %
        %     fName1 = files1(j).name;
        %     [foo1, name, foo2] = fileparts(fName1);
        %     fIn1 = strcat(daily_data_dir, fName1);
        %     fOut1 = strcat(savepathDaily, fName1);
        % %    PSD_auto_20sec(fIn1, fOut1, fName1);
        %      RD_PSD_auto_20sec(fIn1, fOut1, fName1);
        % end
        
        for i = 1:I_MAX% I_MAX
                msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX),...
                        ' | ', int2str(k), ' of ', int2str(length(data))]);   % loading message
                
                disp(msg);
                
                fName = files(i).name;
                [foo1, name, foo2] = fileparts(fName);
                fIn = strcat(DATA_DIR, fName);
%                 fOut = strcat(savepathASL, fName);
%                 energyy(i) = energy_RD(fIn);
                mean_en_change(i) = entropy_video(fIn);
        end
%         savepath = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Energy/Xethru/Change/10energy_change_RD_Video_ASL_',data{k}(1:end-1),'.mat');
%         savepath = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Energy/77 GHz/77energy_change_RD_Video_Daily.mat');
        savepath = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Energy/Video/DailyvideoEnergychange.mat';
        means(k) = mean(mean_en_change);
        save(savepath, 'mean_en_change','means');
        
end
