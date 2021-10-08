function [ ] = rangeDopp_AWR1642( fNameIn, fNameOut, fnameBin )
fileID = fopen(fNameIn, 'r'); % open file
    Data = fread(fileID, 'int16');% DCA1000 should read in two's complement data
    fclose(fileID); % close file
    
    fileSize = size(Data, 1);
    numTX = 1;
    numRX = 4;
    NTS = 256; %64 Number of time samples per sweep
    NoC = 128; % Number of chirp loops
    NPpF = numTX*NoC; % Number of pulses per frame
    fstart = 77e9; % Start Frequency
    fstop = fstart+3.99468e9;%1.79892e9;%   Stop Frequency
    sampleFreq = 5e6; % 2e6 ADC Sampling frequency
    slope = 66.578e12; %29.982e12; % Mhz / us = e6/e-6 = e12
%     numADCBits = 16; % number of ADC bits per sample
    
    fc = (fstart+fstop)/2; % Center Frequency
    c = physconst('LightSpeed'); % Speed of light
    lambda = c/fc; % Lambda
    d = lambda/2; % element spacing (in wavelengths)
    elementPos = (0:numRX-1)*d;
    SweepTime = 40e-3; % Time for 1 frame=sweep
    numChirps = fileSize/2/NTS/numRX;
    NoF = round(numChirps/NPpF); % Number of frames, 4 channels, I&Q channels (2)
    Bw = fstop - fstart; % Bandwidth
    
    dT = SweepTime/NPpF; % 
    prf = 1/dT; 
    timeAxis = linspace(0,SweepTime*NoF,numChirps);%[1:NPpF*NoF]*SweepTime/NPpF ; % Time
    duration = max(timeAxis);
    freqAxis = linspace(-prf/2,prf/2-prf/4096,4096); % Frequency Axis
    
    IFbw = 0.9*sampleFreq/2; % IF bandwidth limited to 0.9*(ADCsampling)/2 
    
    idletime = 100e-6;
    adcStartTime = 6e-6;
    rampEndTime = 60e-6;
    
    LVDS = zeros(1, fileSize/2);
    LVDS(1:2:end) = Data(1:4:end) + sqrt(-1)*Data(3:4:end);
    LVDS(2:2:end) = Data(2:4:end) + sqrt(-1)*Data(4:4:end);
    % check array size (if any frames were dropped, pad zeros)
    if length(LVDS) ~= NTS*numRX*numChirps
       numpad =  NTS*numRX*numChirps - length(LVDS); % num of zeros to be padded
       LVDS = padarray(LVDS, [0 numpad],'post');
    end
    % create column for each chirp
    LVDS = reshape(LVDS, double(NTS*numRX), double(numChirps));
    %% If BPM, i.e. numTX = 2, see MIMO Radar sec. 4.2
    BPMidx = [1:2:numChirps-1];
    if numTX == 2
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
    Np = floor(size(Data(:,1),1)/NTS); % #of pulses
    
    clearvars fileID dataArray ans;
%% Data Collection                                                          
% rawData = zeros(NTS,Np,numLanes);
% fftRawData = zeros(NTS,Np,numLanes);
% for ii = 1:4
%     I_rawData(:,ii) = real(Data(:,ii)); % Real Data
%     Q_rawData(:,ii) = imag(Data(:,ii)); % Imaginary Data
%     Data_Complex(:,ii) = IQcorrection(I_rawData(:,ii),Q_rawData(:,ii)); % Complex Data
%     Colmn = floor(length(Data_Complex(:,1))/NTS);
%     rawData(:,:,ii) = reshape(Data_Complex(:,ii),NTS,Colmn);
%     fftRawData(:,:,ii) = fftshift(fft(rawData(:,:,ii)),1);
%     rp((1:NTS/2),:,ii) = fftRawData(((NTS/2+1):NTS),:,ii); %range profile,color space
% end
% %% MTI Filter
%     [m,n]=size(rp(:,:,1));
%     ns = size(rp,2)+4;                                                      % why +4
%     h=[1 -2 3 -2 1]';                                                      % where h indxs come from
%     rngpro=zeros(m,ns);
%     for k=1:m
%         rngpro(k,:)=conv(h,rp(k,:,1));
%     end
%     
%% Range-Velocity Map
    Rmax = sampleFreq*c/(2*slope);
    Tc = idletime+adcStartTime+rampEndTime;
    Tf = SweepTime;
    velmax = lambda/(Tc*4); % Unambiguous max velocity
    DFmax = velmax/(c/fc/2);
    rResol = c/(2*Bw);
    vResol = lambda/(2*Tf);
    % define frame size
    PN = NTS; %10 equally time spaced matricex: 10X500=5000
    RANGE_FFT_SIZE = NTS*8;  
    DOPPLER_FFT_SIZE = PN*8; %*2

    
    RNGD2_GRID = linspace(0, Rmax, RANGE_FFT_SIZE);
    DOPP_GRID = linspace(DFmax, -DFmax, DOPPLER_FFT_SIZE); 
    
    V_GRID = (c/fc/2)*DOPP_GRID; 

    RData = reshape(Data(1:NTS*Np,1), NTS, Np); % reshape into matrix
                                                % cut out down-chirp slope
%     RData = reshape(sum(Data(:,1:8),2), NTS, Np);

%     rcut = NTS;
%     RCData = RData(1:rcut,:);
    RCData = RData;
    %% MTI increases noise
%     h = [1 -2 1]; % [1 -2 1]
%     RCData = filter(h,1,RCData,[],2);
    
%     f = linspace(77.1799e9,77.9474e9,256);
    %n_frames = floor(size(RCData,2)/PN); % 248
%     n_frames = floor(size(RCData,2)/128); % ~~ 500
    fps = 25;%1/SweepTime;
    n_frames = duration*fps;
    shft = floor(size(RCData,2)/n_frames);
%     RangeVelocityMap = zeros(RANGE_FFT_SIZE/2,RANGE_FFT_SIZE,n_frames);
figure('Visible','off')%,

set(gcf,  'units', 'normalized','position', [0.2 0.2 0.4 0.6])
    for k = 1:n_frames
      
        RData_frame = RCData(:, 1+(k-1)*shft:k*shft);
        RData_frame = bsxfun(@minus, RData_frame, mean(RData_frame,2));   % subtract stationary objects
        G_frame = fftshift(fft2(RData_frame, RANGE_FFT_SIZE,DOPPLER_FFT_SIZE),2); % 2 adjust  shift 
        
%         time_Counter = (k/n_frames)*duration;
        
        imagesc(V_GRID,RNGD2_GRID,20*log10(abs(G_frame)))%+eps)) % /max(abs(G_frame(:)))
%         xlabel('Radial Velocity (m/s)','FontSize',13, 'FontName','Times')
%         ylabel('Range (meter)','FontSize',13, 'FontName','Times')
%         title({'Range-Velocity Map';num2str(time_Counter,'%.2f')},'FontSize',13, 'FontName','Times')
%         colorbar
        clim = get(gca,'CLim');
        set(gca, 'CLim', clim(2)+[-35,0]); % [-35,0],  [left bottom width height]
        caxis([90 120]) % 90 130
%         axis xy;
        axis([-velmax velmax 0 4])
%         axis([-4 4 0 4])
%         set(gcf, 'Position',  [100, 100, size(G_frame,1), size(G_frame,2)])
      colormap(jet) % jet
      F(k) = getframe(gca); % gcf returns the current figure handle
      colormap(gray)
      F2(k) =  getframe(gca);
      drawnow
    end
    
    fGray = [fNameOut(1:end-4) '_gray.avi'];
    
    writerObj = VideoWriter(fNameOut);
    writerObj.FrameRate = fps;
    open(writerObj);
    
    writerObj2 = VideoWriter(fGray);
    writerObj2.FrameRate = fps;
    open(writerObj2);
    
    for i=1:length(F)
        % convert the image to a frame
        frame = F(i) ;    
        writeVideo(writerObj, frame);
        frame2 = F2(i);
        writeVideo(writerObj2, frame2);
    end
    close(writerObj);
    close(writerObj2);
    close all
end