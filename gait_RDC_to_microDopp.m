function [] = gait_RDC_to_microDopp( RDC, fOut )
        
        numADCBits = 16; % number of ADC bits per sample
        SweepTime = 40e-3; % Time for 1 frame
        NTS = size(RDC,1); %256 Number of time samples per sweep
        numADCSamples = NTS;
        numTX = 2; % '1' for 1 TX, '2' for BPM
        NoC = 128;%128; % Number of chirp loops
        NPpF = numTX*NoC; % Number of pulses per frame
        numRX = 4;
        
        numLanes = 2; % do not change. number of lanes is always 4 even if only 1 lane is used. unused lanes
        % NoF = fileSize/2/NPpF/numRX/NTS; % Number of frames
        numChirps = size(RDC,2);
        NoF = round(numChirps/NPpF); % Number of frames, 4 channels, I&Q channels (2)
        dT = SweepTime/NPpF; %
        prf = 1/dT; %
        
        rp = fft(RDC);
        
      %% MTI Filter (not working)
      
%         [m,n]=size(rp(:,:,1));
%         %     ns = size(rp,2)+4;
%         h=[1 -2 3 -2 1]';
%         ns = size(rp,2)+length(h)-1;
%         rngpro=zeros(m,ns);
%         for k=1:m
%                 rngpro(k,:)=conv(h,rp(k,:,1));
%         end
%         
       %% MTI v2
            [b,a]=butter(1, 0.01, 'high'); %  4th order is 24dB/octave slope, 6dB/octave per order of n
        %                                      [B,A] = butter(N,Wn, 'high') where N filter order, b (numerator), a (denominator), ...
        %                                      highpass, Wn is cutoff freq (half the sample rate)
            [m,n]=size(rp(:,:,1));
            rngpro=zeros(m,n);
            for k=1:size(rp,1)
                rngpro(k,:)=filter(b,a,rp(k,:,1));
            end
      %% STFT
    %% STFT
    rBin = 50:170; %covid 18:30, front ignore= 7:nts/2, %lab 15:31 for front
    nfft = 2^12;window = 256;noverlap = 200;shift = window - noverlap;
%      sx = myspecgramnew(rngpro(rBin,:),window,nfft,shift);
     sx = myspecgramnew(sum(rngpro(rBin,:)),window,nfft,shift); % mti filter and IQ correction
    sx2 = abs(flipud(fftshift(sx,1)));
    %% Spectrogram
        timeAxis = [1:NPpF*NoF]*SweepTime/NPpF*numTX ; % Time
        freqAxis = linspace(-prf/2,prf/2,nfft); % Frequency Axis
        fig=figure('visible','on');
        colormap(jet(256));
        imagesc(timeAxis,((3e8)*[-prf/2 prf/2])/(2*77e9),20*log10(sx2./max(sx2(:))));
       set(gcf,'units','normalized','outerposition',[0,0,1,1]);
        %     axis xy
        %     set(gca,'FontSize',10)
        %     title(['RBin: ',num2str(rBin)]);
        %title(fOut(end-28:end-10))
        title('Martelli_2_raw')
        %     xlabel('Time (sec)');
        %     ylabel('Frequency (Hz)');
        caxis([-35 0]) % 40
        set(gca, 'YDir','normal')
        %     colorbar;
        Limit=((3e8)*(1500)/(2*77e9));
        axis([0 timeAxis(end) -Limit Limit])
         %set(gca,'xtick',[],'ytick',[])
           saveas(fig,[fOut(1:end-4) '.fig']);
        %set(gca)
%         frame = frame2im(getframe(gca));
%         imwrite(frame,['Martelli_2_raw.png']);
    close all
        
end