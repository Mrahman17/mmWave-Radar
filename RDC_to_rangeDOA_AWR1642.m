function [] = RDC_to_rangeDOA_AWR1642(RDC, fNameOut, fnameBin)
        
        numTX = 2;
        numRX = 4;
        NTS = size(RDC,1); %64 Number of time samples per sweep
        NoC = 128; % Number of chirp loops
        NPpF = numTX*NoC; % Number of pulses per frame
        fstart = 77e9; % Start Frequency
        fstop = fstart+4e9;%1.79892e9;%   Stop Frequency
        sampleFreq = 6.25e6; % 2e6 ADC Sampling frequency
        slope = 66.578e12; %29.982e12; % Mhz / us = e6/e-6 = e12
        %     numADCBits = 16; % number of ADC bits per sample
        
        fc = (fstart+fstop)/2; % Center Frequency
        c = physconst('LightSpeed'); % Speed of light
        lambda = c/fc; % Lambda
        d = lambda/2; % element spacing (in wavelengths)
        SweepTime = 40e-3; % Time for 1 frame=sweep
        numChirps = size(RDC,2);
        NoF = round(numChirps/NPpF); % Number of frames, 4 channels, I&Q channels (2)
        Bw = fstop - fstart; % Bandwidth
        
        dT = SweepTime/NPpF; %
        prf = 1/dT;
        timeAxis = linspace(0,SweepTime*NoF,numChirps);%[1:NPpF*NoF]*SweepTime/NPpF ; % Time
        duration = max(timeAxis);
        
        idletime = 100e-6;
        adcStartTime = 6e-6;
        rampEndTime = 60e-6;
        
       %% Range Angle Map
        
        Rmax = sampleFreq*c/(2*slope);
        rResol = c/(2*Bw);
        
        RANGE_FFT_SIZE = NTS;
        RNGD2_GRID = linspace(0, Rmax, RANGE_FFT_SIZE);
        
        fps = 25;%1/SweepTime;
        n_frames = duration*fps;
        shft = floor(size(RDC,2)/n_frames);
        opticFlow = opticalFlowHS;
        rangelim = 4;% meters
        ratio = RANGE_FFT_SIZE/Rmax;
        rangelimMatrix = round(ratio*rangelim);
        %% MTI
        h = [1 -2 1]; % [1 -2 1]
        MTI_out  = filter(h,1,RDC,[],2);
%         numFrames = floor(size(RDC,2)/NoC/numTX);
%         rdc4d = reshape(RDC,NTS,NoC*numTX,numRX*numTX,numFrames);
%         rdc4dfft = fft(rdc4d);
        rangeFFT = fft(MTI_out, RANGE_FFT_SIZE);
        M = 10; % # of snapshots
        ang_ax = -60:60;
        d = 0.5;
        
        for k=1:length(ang_ax)
                a1(:,k)=exp(-1i*2*pi*(d*(0:numTX*numRX-1)'*sin(ang_ax(k).'*pi/180)));
        end
        
        figure('visible','off')
        colormap(jet)
        for j = 1:n_frames
                
                for i = 1:RANGE_FFT_SIZE
                        Rxx = zeros(numTX*numRX,numTX*numRX);
                        for m = 1:M
                                if j >= n_frames - M
%                                         idx = (j-M:j)*NoC*numTX;
                                        idx = (j-1)*NoC*numTX-(m-1);
                                        A = squeeze(rangeFFT(i,idx,:));
%                                         A = squeeze(sum(rdc4dfft(i,:,:,j-m+1),2));
                                        
                                else
%                                         idx = (j:M-1+j)*NoC*numTX;
                                        idx = (j-1)*NoC*numTX+(m-1)+1;
                                        A = squeeze(rangeFFT(i,idx,:));
%                                         A = squeeze(sum(rangeFFT(i,idx:idx+NoC,:),2));
%                                         A = squeeze(sum(rdc4dfft(i,:,:,j+m-1),2));
                                end
%                                 A = squeeze(sum(temp,2));
                                Rxx = Rxx + 1/M * (A*A');
                        end
                        %     Rxx = Rxx + sqrt(noise_pow/2)*(randn(size(Rxx))+1j*randn(size(Rxx)));
                        [Q,D] = eig(Rxx); % Q: eigenvectors (columns), D: eigenvalues
                        [D, I] = sort(diag(D),'descend');
                        Q = Q(:,I); % Sort the eigenvectors to put signal eigenvectors first
                        Qs = Q(:,1); % Get the signal eigenvectors
                        Qn = Q(:,2:end); % Get the noise eigenvectors
                        
                        for k=1:length(ang_ax)
                                music_spectrum2(k)=(a1(:,k)'*a1(:,k))/(a1(:,k)'*(Qn*Qn')*a1(:,k));
                        end
                        
                        range_az_music(i,:) = music_spectrum2;
                end
                
             %% Optical Flow Weightening
                raoaFrame = range_az_music(1:rangelimMatrix,:);
                f2 = abs(raoaFrame); %imresize(frame2im(F2), 0.5);
                flow = estimateFlow(opticFlow,f2);
                magnitudes = flow.Magnitude;
                imagesc(ang_ax,RNGD2_GRID(1:rangelimMatrix),20*log10(abs(raoaFrame) .* magnitudes ./ max(abs(raoaFrame(:)))));
                set(gca, 'CLim',[-10,0]); % [-35,0]
%                 axis([min(ang_ax) max(ang_ax) 0 4])
%                 xlabel('Azimuth')
%                 ylabel('Range (m)')
%                 title('MUSIC Range-Angle Map')
%                 clim = get(gca,'clim');
                drawnow
                F(j) = getframe(gca); % gcf returns the current figure handle
                
        end
        
        
        
        writerObj = VideoWriter(fNameOut);
        writerObj.FrameRate = fps;
        open(writerObj);
        
        %     writerObj2 = VideoWriter(fGray);
        %     writerObj2.FrameRate = fps;
        %     open(writerObj2);
        
        for i=1:length(F)
                % convert the image to a frame
                frame = F(i) ;
                writeVideo(writerObj, frame);
                %         frame2 = F2(i);
                %         writeVideo(writerObj2, frame2);
        end
        close(writerObj);
        %     close(writerObj2);
        close all
        
        
        
        
        
        
end