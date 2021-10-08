clc; clear; close all

start_bin_asl = 1;
start_bin_daily = start_bin_asl;
ending_bin = 201;
fps = 25;
putlim = 0; % 0 or 1
action = 1; % 0-sitting, 1-standing, 2-all

mag_file = strcat('77last_RD_aslvsdaily_',num2str(start_bin_asl),'x',num2str(ending_bin),'.mat'); % magnitude function file
dailypath = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Last 77 Daily/*.mat';
ASLpath = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD OF and PSD/Last 77 ASL/*.mat';
mag_path = '/mnt/HDD01/rspl-admin/ASL vs Daily Videos/Fractal Complexity Results/Last 77/';
load(fullfile(mag_path,mag_file));
% magnitude_func_ASL(5) = [];


aslfiles = dir(ASLpath);
dailyfiles = dir(dailypath);
%aslfiles(5) = [];

if action == 0
        idx = [1:42 58:66];
        act = 'Sitting';
elseif action == 1
        idx = [43:57 67:78];
        act = 'Standing';
else
        idx = (1:78);
        act = '(Sitting + Standing)';
end
% dailyfiles = dailyfiles(idx); % use with old method
% magnitude_func_daily = magnitude_func_daily(idx);% use with old method
%% ASL mean magnitude

k=0;
total_asl = 0;
for i =1:length(magnitude_func_ASL)
        if length(magnitude_func_ASL{i})==127%255
                total_asl = total_asl + magnitude_func_ASL{i};
                k = k+1;
        end
end
mean_mag_asl = total_asl/k;
%% Daily mean magnitude
k=0;
total_daily = 0;
for i =1:length(magnitude_func_daily)
        if length(magnitude_func_daily{i})==127%255
                total_daily = total_daily + magnitude_func_daily{i};
                k = k+1;
        end
end
mean_mag_daily = total_daily/k;

%% Plot ASL
fig=figure(1);
hold on 
grid on
sum_asl = 0;
count = 0;
for i = 1:length(aslfiles)
      load(fullfile(aslfiles(i).folder,aslfiles(i).name));
      if size(psdout,2) == 129 % 257 for old
              psdasl= psdout;
              count = count+1;
              sum_asl = sum_asl + psdasl;
              freqaxisASL = linspace(0.01, fps/2, size(psdasl,2));
              
              one_hz_asl = floor(length(freqaxisASL)/(fps/2));
              
              p1 = plot(freqaxisASL(one_hz_asl:end), psdasl(start_bin_asl:ending_bin,one_hz_asl:end)./max(magnitude_func_ASL{i}(one_hz_asl:end)),'-c','LineWidth', 2); % ASL psd
      
      end
      
      
      clear psdout psdasl
end
meanpsdasl = mean(sum_asl(start_bin_asl:ending_bin,:))/count; % one_hz_daily:end
count2 = 0;
sum_daily = 0;
for i = 1:length(dailyfiles)
      load(fullfile(dailyfiles(i).folder,dailyfiles(i).name));
      if exist('psdout1','var') == 1
              psddaily = psdout1;
      end
      if exist('psdout2','var') == 1
              psddaily = psdout2;
      end
      if exist('psdout3','var') == 1
              psddaily = psdout3;
      end
      if size(psdout,2) == 129% 257 with psddaily for old
              freqaxisdaily = linspace(0.01, fps/2, size(psdout,2));
              logaxisdaily = linspace(0,log2(fps/2),size(psdout,2));
              one_hz_daily = floor(length(freqaxisdaily)/(fps/2));
              count2 = count2+1;
              sum_daily = sum_daily + psdout;
              p2 = plot(freqaxisdaily(one_hz_daily:end), psdout(start_bin_daily:ending_bin,one_hz_daily:end)./max(magnitude_func_daily{i}(one_hz_daily:end)),'-m','LineWidth', 2); % daily psd
      end
      clear psdout1 psdout2 psdout3 psddaily
end
meanpsddaily= mean(sum_daily(start_bin_daily:ending_bin,:))/count2;% one_hz_daily:end
p3 = plot(freqaxisdaily(one_hz_daily:end),meanpsddaily(one_hz_daily:end)./max(mean_mag_daily(one_hz_daily:end)),'r', 'LineWidth', 3); % daily mean
p4 = plot(freqaxisASL(one_hz_asl:end), meanpsdasl(one_hz_asl:end)./max(mean_mag_asl(one_hz_asl:end)),'b', 'LineWidth', 3); % ASL mean
p5 = plot(freqaxisdaily(one_hz_daily+1:end-1), mean_mag_daily(one_hz_daily:end)./max(mean_mag_daily(one_hz_daily:end)),'--y', 'LineWidth', 5); % daily magnitude func
p6 = plot(freqaxisASL(one_hz_asl+1:end-1),mean_mag_asl(one_hz_asl:end)./max(mean_mag_asl(one_hz_asl:end)),'--k', 'LineWidth', 5); % ASL magnitude func
legend([p1(1) p2(1) p3 p4 p5 p6],{'ASL PSD','Daily PSD','Daily mean','ASL mean','Daily fit','ASL fit'})
xlim([1 fps/2]);
if putlim == 1
        ylim([0 2]);
end
aslmean = mean(ASL_beta_mean);
dailymean = mean(daily_beta_mean);%mean(daily_beta_mean(idx));
title(['ASL mean Betabar: ',num2str(aslmean,'%8.5f'), ' / Daily mean Betabar: ',num2str(dailymean,'%8.5f')],...
        'FontSize', 18,'fontweight','bold');
xlabel('Frequency (Hz)','FontSize', 18,'fontweight','bold');
ylabel('Normalized PSD','FontSize', 18,'fontweight','bold');
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontName','Times','fontsize',18)
set(gcf, 'units','normalized','Position',  [0.1, 0.2, .8, .7])
savename = strcat('All figures/',mag_file(1:end-4),'_Freq',num2str(putlim),num2str(action),'.fig');
saveas(fig,savename);
%% Log Scale
fig = figure(2);
hold on 
grid on
for i = 1:length(aslfiles)
      load(fullfile(aslfiles(i).folder,aslfiles(i).name));
%       if size(psdout,2) == 257 && length(magnitude_func_ASL{i}) > 128
      if size(psdout,2) == 129 && length(magnitude_func_ASL{i}) > 126        
              psdasl= psdout;
              freqaxisASL= linspace(0.01, fps/2, size(psdasl,2));
              logaxisASL = linspace(0,log2(fps/2),size(psdasl(:,one_hz_asl:end),2));
              one_hz_asl = floor(length(freqaxisASL)/(fps/2));
              
              p1 = plot(logaxisASL, log2(psdasl(start_bin_asl:ending_bin,one_hz_asl:end)./max(magnitude_func_ASL{i}(one_hz_asl:end))),'-c','LineWidth', 2); % ASL psd
      
      end
      
      
      clear psdout psdasl
end
cnt3 = 0;
for i = 1:length(dailyfiles)
      load(fullfile(dailyfiles(i).folder,dailyfiles(i).name));
      if exist('psdout1','var') == 1
              psddaily = psdout1;
      end
      if exist('psdout2','var') == 1
              psddaily = psdout2;
      end
      if exist('psdout3','var') == 1
              psddaily = psdout3;
      end
      psddaily = psdout;
      if size(psddaily,2) == 129%257
              
              freqaxisdaily = linspace(0.01, fps/2, size(psddaily,2));
              one_hz_daily = floor(length(freqaxisdaily)/(fps/2));
              logaxisdaily = linspace(0,log2(fps/2),size(psddaily(:,one_hz_daily:end),2));
              cnt3 = cnt3+1;
              
              p2 = plot(logaxisdaily, log2(psddaily(start_bin_daily:ending_bin,one_hz_daily:end)./max(magnitude_func_daily{i}(one_hz_daily:end))),'-m','LineWidth', 2); % daily psd
      end
      clear psdout1 psdout2 psdout3 psddaily
end
p3 = plot(logaxisdaily,log2(meanpsddaily(one_hz_daily:end)./max(mean_mag_daily(one_hz_daily:end))),'r', 'LineWidth', 3); % daily mean
p4 = plot(logaxisASL, log2(meanpsdasl(one_hz_asl:end)./max(mean_mag_asl(one_hz_asl:end))),'b', 'LineWidth', 3); % ASL mean
p5 = plot(logaxisdaily(2:end-1), log2(mean_mag_daily(one_hz_daily:end)./max(mean_mag_daily(one_hz_daily:end))),'--y', 'LineWidth', 5); % daily magnitude func
p6 = plot(logaxisASL(2:end-1),log2(mean_mag_asl(one_hz_asl:end)./max(mean_mag_asl(one_hz_asl:end))),'--k', 'LineWidth', 5); % ASL magnitude func
legend([p1(1) p2(1) p3 p4 p5 p6],{'ASL PSD','Daily PSD','Daily mean','ASL mean','Daily fit','ASL fit'})
xlabel('Log_{2} (Hz)','FontSize', 18,'fontweight','bold');
ylabel('Normalized PSD','FontSize', 18,'fontweight','bold');
if putlim == 1
        ylim([-4 4]);
end
xlim([0 log2(fps/2)]);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontName','Times','fontsize',18)
set(gcf, 'units','normalized','Position',  [0.1, 0.2, .8, .7])
title(['ASL mean Betabar: ',num2str(aslmean,'%8.5f'), ' / Daily mean Betabar: ',num2str(dailymean,'%8.5f')],...
        'FontSize', 18,'fontweight','bold');
savename = strcat('All figures/',mag_file(1:end-4),'_Log',num2str(putlim),num2str(action),'.fig');
saveas(fig,savename);







