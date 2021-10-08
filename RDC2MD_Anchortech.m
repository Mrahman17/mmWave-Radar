function []=RDC2MD_Anchortech( Data_time, fOut,Tsweep)
        %Part taken from Ancortek code for FFT and IIR filtering
        NTS = size(Data_time,1);
        tmp = fftshift(fft(Data_time),1);
        Data_range(1:NTS/2,:) = tmp(NTS/2+1:NTS,:);
        % Data_range = tmp;
        % IIR Notch filter
        ns = oddnumber(size(Data_range,2))-1;
        Data_range_MTI = zeros(size(Data_range,1),ns);
        [b,a] = butter(4, 0.01, 'high');
        % [h, f1] = freqz(b, a, ns);
        for k=1:size(Data_range,1)
                Data_range_MTI(k,:) = filter(b,a,Data_range(k,:));
        end
        
        %% Spectrogram processing for 2nd FFT to get Doppler
        % This selects the range bins where we want to calculate the spectrogram
        bin_indl = 3;
        bin_indu = 60;
        %Parameters for spectrograms
        MD.PRF=1/Tsweep;
        MD.TimeWindowLength = 200;
        MD.OverlapFactor = 0.95;
        MD.OverlapLength = round(MD.TimeWindowLength*MD.OverlapFactor);
        MD.Pad_Factor = 4;
        MD.FFTPoints = MD.Pad_Factor*MD.TimeWindowLength;
        MD.DopplerBin=MD.PRF/(MD.FFTPoints);
        MD.DopplerAxis=-MD.PRF/2:MD.DopplerBin:MD.PRF/2-MD.DopplerBin;
        MD.WholeDuration=size(Data_range_MTI,2)/MD.PRF;
        MD.NumSegments=floor((size(Data_range_MTI,2)-MD.TimeWindowLength)/floor(MD.TimeWindowLength*(1-MD.OverlapFactor)));
        
        nfft = 2^12;window = 128;noverlap = 100;shift = window - noverlap;
        sx = myspecgramnew(sum(Data_range_MTI(18:21,:)),window,nfft,shift); % best bin 19-20 for asl
        sx1 = flipud(fftshift(sx,1));
        sx_scaled = sx1(1408:3688,:);
        sx2 = abs(sx1);
        MD.TimeAxis=linspace(0,MD.WholeDuration,size(Data_range_MTI,2));

        
        % fig= figure('visible','on','units','normalized','outerposition',[0 0 .5 .5]);
         figure('visible','off');
        colormap(jet(256));
        imagesc(MD.TimeAxis,MD.DopplerAxis,20*log10(abs(sx2./max(max(sx2))))); % normalization = /max(max(abs(Data_spec_MTI2)))
        set(gcf,'units','normalized','outerposition',[0,0,1,1]);
        %     axis xy
        %     set(gca,'FontSize',10)
        %     title(['RBin: ',num2str(rBin)]);
        title(fOut(end-28:end-10))
        %     xlabel('Time (sec)');
        %     ylabel('Frequency (Hz)');
        clim = get(gca,'CLim');
        set(gca, 'CLim', clim(2)+[-30,5]);
        set(gca, 'YDir','normal')
        %     colorbar;
        %axis([0 timeAxis(end) -prf/6 prf/6])
        %     saveas(fig,[fOut(1:end-4) '.fig']);
        set(gca,'xtick',[],'ytick',[])
        frame = frame2im(getframe(gca));
        imwrite(frame,[fOut(1:end-4) '.png']);
        close all
        