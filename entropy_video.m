function [ meanchange ] = entropy_video( fIn)

v = VideoReader(fIn);

opticFlow = opticalFlowHS;
stopFrame = 8 *v.FrameRate; % use first 8 seconds
%abs_mag = zeros(v.Width*v.Height,100);
for i= 1:stopFrame
    frameRGB = readFrame(v);
    frameGray = rgb2gray(frameRGB);
    frameGray2 = imresize(frameGray, 0.2);
    flow = estimateFlow(opticFlow,frameGray2);
%         x_vel(:,:,i) = flow.Vx; % y direction is top to bottom and x direction is left to right 
%          y_vel(:,:,i) = flow.Vy; % for RD map
       magnitudes(:,:,i) = flow.Magnitude;
%         orientations(:,:,i) = flow.Orientation;
%         abs_mag(:,i) = reshape(abs(magnitudes(:,:,i)),1,size(frameGray2,1)*size(frameGray2,2));
%     imshow(frameRGB)
%     hold on
%     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10,'Parent',hPlot);
%     % Find quiver handle
%     q = findobj(gca,'type','Quiver');
%     % Change color to red
%     q.Color = 'r';
%     hold off
    energyy(i) = sum(magnitudes(:));  
    if i > 1
            change(i-1) = abs(energyy(i)-energyy(i-1));
    end
end
meanchange = mean(change);
end

