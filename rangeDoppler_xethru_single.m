clc; clear close all;

filename = 'C:\Users\mrahman17\Desktop\Xethru_ASL\sub1\radar_06\06560022_1557518509.dat';

fid = fopen(filename, 'rb');

ctr = 0;

while(1)
       

    ContentId=fread(fid,1,'uint32');
    Info=fread(fid,1,'uint32');
 
    ctr=ctr+1; 
    Length=fread(fid,1,'uint32');
    Data=fread(fid,182,'float');
    
    if feof(fid)
           break
    end
        
    Datastream(:,ctr)=Data;
    data_length(ctr)=Length;

  
end 
for n=1:size(Datastream,2)
        Data=Datastream(:,n);
        iq_mat(:,n) = Data(1:end/2) + 1i*Data(end/2 + 1:end);
end
%% Parameters
Bw = 1.5e9;
NTS = size(iq_mat,1); % 128 in ancortek
Np = size(iq_mat,2); % #of pulses 20k in ancortek
Tsweep = 0.001954; % 1e-3 in ancortek
fc = 8.748e9; % Center frequency, 2.5e10 in ancortek
c = physconst('LightSpeed'); % Speed of light
record_length= Np*Tsweep; % length of recording in s
fs=NTS/Tsweep; % sampling frequency ADC - 128000 in ancortek
nc=record_length/Tsweep; % number of chirps 20k in ancortek
%% MTI Filter
[b,a]=butter(4, 0.01, 'high'); %  4th order is 24dB/octave slope, 6dB/octave per order of n
                                 % [B,A] = butter(N,Wn, 'high') where N filter order, b (numerator), a (denominator), ...
                                 % highpass, Wn is cutoff freq (half the sample rate)
[h,fl]=freqz(b,a,size(iq_mat,2));
for k=1:size(iq_mat,1)
    Data_RTI_complex_MTIFilt(k,:)=filter(b,a,iq_mat(k,:));
end
%% Range-Velocity Map
    Rmax = c*NTS/(4*Bw); % maximum range 
    %DFmax = (1/(Tsweep*1e-3))/2; % maximum (unambiguous) Doppler 
    DFmax = (1/Tsweep)/2; % maximum (unambiguous) Doppler 
    Vmax = c/fc/(4*Tsweep);
    % define frame size
    PN = NTS; %10 equally time spaced matricex: 10X500=5000
    RANGE_FFT_SIZE = NTS*2;  
    DOPPLER_FFT_SIZE = PN*2; 

    
    RNGD2_GRID = linspace(0, Rmax, RANGE_FFT_SIZE/2);
    DOPP_GRID = linspace(-DFmax, DFmax, DOPPLER_FFT_SIZE); 
    
    V_GRID = (c/fc/2)*DOPP_GRID; 

    RData = iq_mat; % reshape into matrix
                                                % cut out down-chirp slope
    rcut = NTS;
    RCData = RData(1:rcut,:);
    
%     f = linspace(77.1799e9,77.9474e9,256);
    %n_frames = floor(size(RCData,2)/PN); % 248
%     n_frames = floor(size(RCData,2)/40); % ~~ 500
    fps = 25;
    n_frames = floor(record_length*fps);
    RangeVelocityMap = zeros(RANGE_FFT_SIZE/2,DOPPLER_FFT_SIZE,n_frames);
    shift = floor(size(RCData,2)/n_frames);
    figure(1)
    for k = 1:n_frames
      
      %%%%%%%%%%% CREATE RANGE-VELOCITY-TIME DATA CUBE
    
        %RData_frame = RCData(:, 1+(k-1)*PN:k*PN);
        RData_frame = RCData(:, 1+(k-1)*shift:k*shift);
        % subtract stationary objects
        RData_frame = bsxfun(@minus, RData_frame, mean(RData_frame,2));   
        G_frame = fftshift(fft2(RData_frame, RANGE_FFT_SIZE/2,DOPPLER_FFT_SIZE)); %adjust  shift 
%         G_frame = G_frame(RANGE_FFT_SIZE/2+1:end,:);
        RangeVelocityMap(:,:,k) = G_frame;
        %time_Counter = (k/250)*20;
        time_Counter = (k/n_frames)*record_length;
        colormap(gray)        
        imagesc(V_GRID,RNGD2_GRID,20*log10(abs(G_frame)))
        xlabel('Radial Velocity (m/s)')
        ylabel('Range (meter)')
        title({'Range-Velocity Map';time_Counter})
        colorbar
        clim = get(gca,'CLim');
        set(gca, 'CLim', clim(2)+[-35,0]);
%         caxis([50 70])
        caxis([-45 0]);
        axis xy;
        axis([-Vmax Vmax 0 Rmax])
      
      F(k) = getframe(gca); % gcf returns the current figure handle
      drawnow
      
    end
