function [energyy] = energy_RD(fIn)
        
v = VideoReader(fIn);
stopFrame = 8 *v.FrameRate; % use first 8 seconds
midpoint = floor((v.Width-4)/2); % first and last 2 columns are white
power = zeros(v.Height,v.Width-4); % first and last 2 columns are white
for i= 1:stopFrame
    frameRGB = readFrame(v);
    frameGray = rgb2gray(frameRGB); 
    frameGray = double(frameGray(:,3:end-2));
    for k = 1:v.Width-4
            power(:,k) = frameGray(:,k) * abs(k-midpoint);
    end
        
end   
energyy = sum(power(:));
end