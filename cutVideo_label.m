function [] = cutVideo_label(fIn, fOut, beginFrame, endFrame) 
a = VideoReader(fIn);
vidObj = VideoWriter(fOut);
vidObj.FrameRate = 25;
open(vidObj);
for img = beginFrame:endFrame
    b = read(a, img);
    writeVideo(vidObj,b)
end
close all
end