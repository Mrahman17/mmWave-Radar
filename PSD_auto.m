function [ ] = PSD_auto( fNameIn, fNameOut, fnameBin )
% clear; clc; warning off; close all;
% 
% video_dir = 'C:\Users\mrahman17\Desktop\77 GHz\output_77_20\Exp4\sub1_video\';
% video_name = '09640022.avi';
% 
%  video = strcat (video_dir, '\', video_name);
v = VideoReader(fNameIn);
%v = VideoReader(video);

h = figure('Visible', 'off');
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

%opticFlow = opticalFlowLK('NoiseThreshold',0.009);
opticFlow = opticalFlowHS;
i = 1;
%abs_mag = zeros(v.Width*v.Height,100);
while hasFrame(v)
    frameRGB = readFrame(v);
    frameGray = rgb2gray(frameRGB);
    frameGray2 = imresize(frameGray, 0.2);
    flow = estimateFlow(opticFlow,frameGray2);
%         x_vel(:,:,i) = flow.Vx; % X direction is top to bottom and Y direction is left to right 
%          y_vel(:,:,i) = flow.Vy;
       magnitudes(:,:,i) = flow.Magnitude;
%         orientations(:,:,i) = flow.Orientation;
        abs_mag(:,i) = reshape(abs(magnitudes(:,:,i)),1,size(frameGray2,1)*size(frameGray2,2));
%     imshow(frameRGB)
%     hold on
%     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10,'Parent',hPlot);
%     % Find quiver handle
%     q = findobj(gca,'type','Quiver');
%     % Change color to red
%     q.Color = 'r';
%     hold off
    i = i + 1;
end
%% Optical Flow

bin_size = (max(abs_mag(:))-min(abs_mag(:)))/200;
num_bins = round(max(abs_mag(:))/bin_size)+1; %
bin_axis = linspace(0, max(abs_mag(:)),num_bins);
%bin_axis = bin_axis.';
%bin_axis = fliplr(bin_axis);
[r, c] = size(abs_mag);
hist_mag = zeros(num_bins,c);

for f = 1:c
    for i = 1:r
        a = num_bins-round(abs_mag(i,f)/bin_size);
        hist_mag(a,f) = hist_mag(a,f) + 1;
    end
end
histeightsec = hist_mag(:,1:v.FrameRate*8);
timeaxis = linspace(0,8,v.FrameRate*8);
fig = figure('Visible','on');
colormap(jet(256));
% imagesc([],bin_axis,20*log10(flipud(hist_mag)));
imagesc(timeaxis,bin_axis,20*log10(flipud(histeightsec)));
% title({'Optical Flow Diagram of: ',fnameBin});
xlabel('Time (sec)');
ylabel('Optical Flow (px/frame)');
caxis([0 30])
set(gca,'YDir','normal','fontweight','bold','fontsize',12)
set(gcf,'color','w');
colorbar;
savenameOF = strcat(fNameOut(1:(end-4)),'_OF.fig');
saveas(fig,savenameOF);
%% PSD
FPS = v.FrameRate;
freqaxis = linspace(0, FPS/2); % 25 FPS
[m, n] = size(hist_mag);
window = n; noverlap = 5*window/6; 
psd = pwelch(hist_mag', window, noverlap);
psdout = psd';
fig = figure('Visible','on');
colormap(jet(256));
%imagesc(freqaxis, bin_axis,20*log10(psd')/max(max(psd)));
imagesc(freqaxis, bin_axis, 20*log10(flipud(psdout)));
%set(gca,'YtickLabel',max(abs_mag(:)):-1:0)
title({'Power Spectral Density of ', fnameBin(1:end-4)});
xlabel('Frequency (Hz)');
ylabel('Optical Flow (px/frame)');
caxis([-150 100])
set(gca,'YDir','normal')
savePSD = strcat(fNameOut(1:end-4),'_PSD.mat');
save(savePSD,'psdout');
savename = strcat(fNameOut(1:(end-4)),'_PSD.fig');
saveas(fig,savename);
end