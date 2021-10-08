function [] = microDoppler_AWR1642_bulk_BPM(fname, fOut)
    % read .bin file
    fid = fopen(fname,'r');
    % DCA1000 should read in two's complement data
    Data = fread(fid, 'int16');
    fclose(fid);
    %% Parameters
    fileSize = size(Data, 1);

    numADCBits = 16; % number of ADC bits per sample
    SweepTime = 40e-3; % Time for 1 frame
    NTS = 256; %256 Number of time samples per sweep
    numADCSamples = NTS;
    numTX = 2; % '1' for 1 TX, '2' for BPM
    NoC = 128;%128; % Number of chirp loops
    NPpF = numTX*NoC; % Number of pulses per frame
    numRX = 4;
    
    numLanes = 2; % do not change. number of lanes is always 4 even if only 1 lane is used. unused lanes
    % NoF = fileSize/2/NPpF/numRX/NTS; % Number of frames
    numChirps = ceil(fileSize/2/NTS/numRX);
    NoF = round(numChirps/NPpF); % Number of frames, 4 channels, I&Q channels (2)
    Np = numChirps;%floor(size(Data(:,1),1)/NTS); % #of pulses
    dT = SweepTime/NPpF; % 
    prf = 1/dT; %
    dR=(3e8)/(2*4e9);
    F=NTS/dT;
       LVDS = zeros(1, fileSize/2);
    LVDS(1:2:end) = Data(1:4:end) + sqrt(-1)*Data(3:4:end);
    LVDS(2:2:end) = Data(2:4:end) + sqrt(-1)*Data(4:4:end);
    % check array size (if any frames were dropped, pad zeros)
    if length(LVDS) ~= NTS*numRX*numChirps
       numpad =  NTS*numRX*numChirps - length(LVDS); % num of zeros to be padded
       LVDS = padarray(LVDS, [0 numpad],'post');
    end
    
    if rem(length(LVDS), NTS*numRX) ~= 0
          LVDS = [LVDS zeros(1, NTS*numRX - rem(length(LVDS), NTS*numRX))];  
    end
    LVDS = reshape(LVDS, NTS*numRX, numChirps);
    %% If BPM, i.e. numTX = 2, see MIMO Radar sec. 4.2
    
    if numTX == 2
            if rem(size(LVDS,2),2) ~= 0
                    LVDS = [LVDS LVDS(:,end)];
                    numChirps = numChirps + 1;
            end
            BPMidx = [1:2:numChirps-1];
            LVDS_TX0 = 1/2 * (LVDS(:,BPMidx)+LVDS(:,BPMidx+1));
            LVDS_TX1 = 1/2 * (LVDS(:,BPMidx)-LVDS(:,BPMidx+1));
            LVDS0 = kron(LVDS_TX0,ones(1,2));
            LVDS1 = kron(LVDS_TX1,ones(1,2));
            LVDS = zeros(NTS*numRX*numTX,numChirps);
            LVDS(1:end/2,:) = LVDS0;
            LVDS(end/2+1:end,:) = LVDS1;
    end
    %%
    Data = zeros(numChirps*NTS, numRX*numTX);
    for i = 1:numRX*numTX
        Data(:,i) = reshape(LVDS((i-1)*NTS+1:i*NTS,:),[],1);
    end
    
    rawData = reshape(Data,NTS,numChirps, numRX*numTX); 
    
    %% No IQ Correction
  
    rp = fft(rawData);
%     rp2=fftshift(fft2(rawData,256,128000),2);
%      figure; imagesc(V,R, 20*log10(abs(rp2(:,:,1))/max(max(abs(rp2(:,:,1))))));
%     figure; imagesc(timeAxis,R, 20*log10(abs(rp(:,:,1))/max(max(abs(rp(:,:,1))))));
    clear Data
     %% MTI Filter (not working)
%         [m,n]=size(rp(:,:,1));
%         %     ns = size(rp,2)+4;
%         h=[1 -2 3 -2 1]';
%         ns = size(rp,2)+length(h)-1;
%         rngpro=zeros(m,ns);
%         for k=1:m
%                 rngpro(k,:)=conv(h,rp(k,:,1));
%         end
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
        title(fOut(end-28:end-10))
        %     xlabel('Time (sec)');
        %     ylabel('Frequency (Hz)');
        caxis([-35 0]) % 40
        set(gca, 'YDir','normal')
        %     colorbar;
        Limit=((3e8)*(prf/4)/(2*77e9));
        axis([0 timeAxis(end) -Limit Limit])
         %set(gca,'xtick',[],'ytick',[])
           saveas(fig,[fOut(1:end-4) '.fig']);
        %set(gca)
        frame = frame2im(getframe(gca));
        imwrite(frame,[fOut(1:end-4) '.png']);
    close all
end