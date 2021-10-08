
clc; clear; close all; warning off;
dataasl = {'radar_06/', 'radar_07/', 'radar_08/'};
datadaily = {'Front/', 'Corner/', 'Side/'};

for k=1:3 
%         DATA_DIR= strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD ASL/Xethru/',dataasl{k}, 'Cut/');
        DATA_DIR = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD ASL/Gray Cut/';
%         DATA_DIR = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/ASL video/';
        pattern = strcat(DATA_DIR, '*.avi');    % file pattern
        files = dir(pattern);
%         savepathASL = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Xethru ASL/',data{k});
        savepathASL = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Last 10 ASL/',dataasl{k});
        I_MAX = numel(files); % # of files in "files"
        
%         daily_data_dir= '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD Daily/Gray/';
        daily_data_dir = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD Daily/Xethru/Gray/',datadaily{k});
        savepathDaily = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Last 10 Daily/',datadaily{k});
        pattern1 = strcat(daily_data_dir, '*.avi');    % file pattern
        files1 = dir(pattern1);
        J_MAX=numel(files1);
        
        for i = 2:I_MAX% I_MAX
                msg = strcat(['Processing file ', int2str(i), ' of ', int2str(J_MAX+I_MAX),...
                        ' | ', int2str(k), ' of ', int2str(length(dataasl))]);   % loading message
                %     waitbar(i/I_MAX, w, msg);
                disp(msg);
                
                fName = files(i).name;
                [foo1, name, foo2] = fileparts(fName);
                fIn = strcat(DATA_DIR, fName);
                fOut = strcat(savepathASL, fName);
%                 PSD_auto(fIn, fOut, fName);
                %     RD_PSD_auto(fIn, fOut, fName);
                RD_OF(fIn,fOut,fName);
        end
        
        for j=1:J_MAX
            msg = strcat(['Processing file ', int2str(j+i), ' of ', int2str(J_MAX+I_MAX),...
                    ' | ', int2str(k), ' of ', int2str(length(dataasl))]); % loading message
        %     waitbar(j/J_MAX, w, msg);
            disp(msg);
        
            fName1 = files1(j).name;
            [foo1, name, foo2] = fileparts(fName1);
            fIn1 = strcat(daily_data_dir, fName1);
            fOut1 = strcat(savepathDaily, fName1);
        %    PSD_auto_20sec(fIn1, fOut1, fName1);
%              RD_PSD_auto_20sec(fIn1, fOut1, fName1);
             RD_OF(fIn1,fOut1,fName1);
             
        end
        
        
end
% close(w);
