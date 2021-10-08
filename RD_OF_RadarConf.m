function [] = RD_OF_RadarConf(fIn,fOut,fnameBin)
        
v = VideoReader(fIn);
windowx = 0.2;
stopFrame = floor(v.FrameRate*windowx); % use every 0.2 seconds
midpoint = floor((v.Width-4)/2); % first and last 2 columns are white
power = zeros(v.Height,v.Width-4); % first and last 2 columns are white
cnt = stopFrame;
while cnt < v.Duration*v.FrameRate
        for i= 1:stopFrame
                frameRGB = readFrame(v);
                frameGray = rgb2gray(frameRGB);
                frameGray2 = frameGray(:,3:end-2);%double(frameGray(:,3:end-2));
                for k = 1:v.Width-4
                        power(:,k) = frameGray2(:,k) * abs(k-midpoint);
                        
                end
                abs_mag(:,i) = reshape(power,1,size(frameGray2,1)*size(frameGray2,2));
                %     energyy(i) = sum(power(:));
                %     if i > 1
                %             change(i-1) = abs(energyy(i)-energyy(i-1));
                %     end
                
        end
        %% Optical Flow
        abs_mag2 = rescale(abs_mag, 0, 1);
        bin_size = (max(abs_mag2(:))-min(abs_mag2(:)))/200;
        num_bins = round(max(abs_mag2(:))/bin_size)+1; %
        bin_axis = linspace(0, max(abs_mag2(:)),num_bins);
        %bin_axis = bin_axis.';
        %bin_axis = fliplr(bin_axis);
        [r, c] = size(abs_mag2);
        hist_mag = zeros(num_bins,c);
        
        for f = 1:c
                for i = 1:r
                        a = num_bins-round(abs_mag2(i,f)/bin_size);
                        hist_mag(a,f) = hist_mag(a,f) + 1;
                end
        end
%         timeaxis = 1:stopFrame/v.FrameRate;
        timeaxis = 0:stopFrame;
        plothist = 20*log10(flipud(hist_mag(3:end-3,:)))./max(max(hist_mag(3:end-3,:)));
        % plothist = flipud(hist_mag)./max(hist_mag(:));
        fig = figure('Visible','off');
        colormap(jet(256));
        imagesc(timeaxis,bin_axis(3:end-3),plothist);
        % imagesc(timeaxis,bin_axis,flipud(hist_mag));
        % title({'Optical Flow Diagram of: ',fnameBin});
        xlabel('Frames','fontweight','bold','fontsize',10);
        ylabel('Normalized Intensity Weighted Velocity (dB)','fontweight','bold','fontsize',10);
        % caxis([0 30])
        caxis([min(plothist(:)) max(plothist(:))])
        set(gca,'YDir','normal','fontweight','bold','fontsize',12)
        set(gcf,'color','w');
        colorbar;
        savenameOF = strcat(fOut(1:(end-4)),'_OF',num2str(cnt),'.fig');
        saveas(fig,savenameOF);
        %% PSD
        FPS = v.FrameRate;
        freqaxis = linspace(0, FPS/2); % 25 FPS
        [m, n] = size(hist_mag);
        window = n; noverlap = 4*window/5;
        psd = pwelch(hist_mag', window, noverlap);
        psdout = psd';
        fig = figure('Visible','off');
        colormap(jet(256));
        %imagesc(freqaxis, bin_axis,20*log10(psd')/max(max(psd)));
        imagesc(freqaxis, bin_axis, 20*log10(flipud(psdout)));
        %set(gca,'YtickLabel',max(abs_mag(:)):-1:0)
        title({'Power Spectral Density of ', fnameBin(1:end-4)});
        xlabel('Frequency (Hz)');
        ylabel('Optical Flow (px/frame)');
        caxis([-150 100])
        set(gca,'YDir','normal')
        savePSD = strcat(fOut(1:end-4),'_PSD',num2str(cnt),'.mat');
        save(savePSD,'psdout');
        savename = strcat(fOut(1:(end-4)),'_PSD',num2str(cnt),'.fig');
        saveas(fig,savename);
        cnt = cnt+stopFrame;
end
        
end