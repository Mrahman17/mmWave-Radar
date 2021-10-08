function [ ] = datToImage_77( fNameIn, fNameOut)
    fileID = fopen(fNameIn, 'r'); % open file
    Data = fread(fileID, 'int16');% DCA1000 should read in two's complement data
    fclose(fileID); % close file

    numADCBits = 16; % number of ADC bits per sample
    numLanes = 4; 
    fstart = 77.1799e9; % Start Frequency
    fstop = 77.9474e9; % Stop Frequency
    fc = (fstart+fstop)/2; % Center Frequency
    c = physconst('LightSpeed'); % Speed of light
    lambda = c/fc; % Lambda
    SweepTime = 40e-3; % Time for 1 frame=sweep
    NTS = 256; % Number of time samples per sweep                               
    NPpF = 128; % Number of pulses per frame
    NoF = 500; % Number of frames
    Bw = fstop - fstart; % Bandwidth
    sampleRate = 10e6; % Smpling Rate
    dT = SweepTime/NPpF; % 
    prf = 1/dT; 
    timeAxis = [1:NPpF*NoF]*SweepTime/NPpF ; % Time
    freqAxis = linspace(-prf/2,prf/2-prf/4096,4096); % Frequency Axis
    
    % reshape and combine real and imaginary parts of complex number
    Data = reshape(Data, numLanes*2, []);
    Data = Data(1:4,:) + sqrt(-1)*Data(5:8,:);                                  
    Data = Data.';
    Np = floor(size(Data(:,1),1)/NTS); % #of pulses
    
    clearvars fileID dataArray ans;
%% IQ Correction
rawData = zeros(NTS,Np,numLanes);
fftRawData = zeros(NTS,Np,numLanes);
% for ii = 1:4
%     I_rawData(:,ii) = real(Data(:,ii)); % Real Data
%     Q_rawData(:,ii) = imag(Data(:,ii)); % Imaginary Data
%     Data_Complex(:,ii) = IQcorrection(I_rawData(:,ii),Q_rawData(:,ii)); % Complex Data
%     Colmn = floor(length(Data_Complex(:,1))/NTS);
%     rawData(:,:,ii) = reshape(Data_Complex(:,ii),NTS,Colmn);
%     fftRawData(:,:,ii) = fftshift(fft(rawData(:,:,ii)),1);
%     rp((1:NTS/2),:,ii) = fftRawData(((NTS/2+1):NTS),:,ii); %range profile,color space
% end
%% No IQ Correction
for ii = 1:4
    Colmn = floor(length(Data(:,1))/NTS);
    rawData(:,:,ii) = reshape(Data(:,ii),NTS,Colmn);
    fftRawData(:,:,ii) = fftshift(fft(rawData(:,:,ii)),1);
    rp((1:NTS/2),:,ii) = fftRawData(((NTS/2+1):NTS),:,ii); %range profile,color space
end
%% MTI Filter
    [m,n]=size(rp(:,:,1));
    ns = size(rp,2)+4;                                                      % why +4
    h=[1 -2 3 -2 1]';                                                      % where h indxs come from
    rngpro=zeros(m,ns);
    for k=1:m
        rngpro(k,:)=conv(h,rp(k,:,1));
    end
%% MTI 2
%  [b,a]=butter(4, 0.01, 'high'); %  4th order is 24dB/octave slope, 6dB/octave per order of n
%                                  % [B,A] = butter(N,Wn, 'high') where N filter order, b (numerator), a (denominator), ...
%                                  % highpass, Wn is cutoff freq (half the sample rate)
% for k=1:size(rp,1)
%     rngpro(k,:)=filter(b,a,rp(k,:,1));
% end   
%% Micro-DopplerSpectrogram Data  Time vs Freq
% for ii = 1:4
%     rawData(:,:,ii) = rawData(:,:,ii) - repmat(mean(rawData(:,:,ii),2),[1,size(rawData(:,:,ii),2)]);% normalization
%     fftRawData(:,:,ii) = fft(rawData(:,:,ii));
%     rng = fftRawData(1:NTS/2,:,ii);                                     
%     x(:,:,ii)=sum(rng(7:10,:));                                         % not get it
% end
      rBin = 23:30; %26:%covid 18:30, front ingore= 7:nts/2, %lab 15:31 for front
    nfft = 2^12;window = 256;noverlap = 200;shift = window - noverlap;
%       sx = myspecgramnew(rngpro(rBin,:),window,nfft,shift);
   sx = myspecgramnew(sum(rngpro(rBin,:,1)),window,nfft,shift); % mti filter and IQ correction
    sx2 = abs(flipud(fftshift(sx,1)));
    time = dT * length(Data)/NTS;
%     imwrite(rescale(abs(sx1),0,255),fNameOut);
    fig = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
    colormap(jet(256));
   doppSignMTI = imagesc(timeAxis,[-prf/2 prf/2],20*log10(abs(sx2/max(sx2(:)))));
 %     axis xy
%     set(gca,'FontSize',10)
    title(['RBin: ',num2str(rBin)]);
%     title(fOut(end-22:end-4))
%     xlabel('Time (sec)');
%     ylabel('Frequency (Hz)');
    caxis([-45 0]) % 40
    set(gca, 'YDir','normal')
%     colorbar;
    axis([0 timeAxis(end) -prf/6 prf/6])
    saveas(fig,[fNameOut(1:end-4) '.fig']);
    set(gca,'xtick',[],'ytick',[])
%     frame = frame2im(getframe(gca));
%     imwrite(frame,[fOut(1:end-4) '.png']);
    close all
end