function [] = cutVideo(fIn, fOut, beginTime, endTime) 
a = VideoReader(fIn);
beginFrame = beginTime * a.FrameRate + 1;
endFrame = endTime * a.FrameRate;
vidObj = VideoWriter(fOut);
vidObj.FrameRate = 25;
open(vidObj);
for img = beginFrame:endFrame
    b = read(a, img);
    writeVideo(vidObj,b)
end
close(vidObj);