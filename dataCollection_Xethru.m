clear; clc; close all; warning off;
data = {'Front/', 'Corner/', 'Side/'};
beginTime = 0;
endTime = [9 12 17 9 9 14 10 13 11 ...
        8 10 10 9 12 14 12 14 15 11 ...
        15 9 9 11 12 9 15 12 12 14];
for j = 1:length(data)
    DATA_DIR = strcat('/media/rspl-admin/FantomHD/Daily Data/20 Jan 2020/Xethru/',data{j});           % ** Adjust acc to your pattern**
    OUT_DIR = strcat('/mnt/HDD01/rspl-admin/ASL vs Daily Videos/RD Daily/Xethru/Gray/',data{j});     % ** Adjust acc to your pattern**

    pattern = strcat(DATA_DIR, '*.dat');    % file pattern
    files = dir(pattern);

    I_MAX = numel(files); % # of files in "files" 

    for i = 1:30%I_MAX   % for the first 20 iteration
        tic
        msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX),...
                ' | ', int2str(j), ' of ', int2str(length(data))]);   % loading message
        disp(msg);

        fName = files(i).name;
        [foo1, name, foo2] = fileparts(fName);
        fIn = fullfile(files(i).folder, files(i).name);
        fOut = strcat(OUT_DIR, name, '.png');
        fOut_vid = strcat(OUT_DIR, name, '.avi');

    %     XeThru_mDopp_bulk(fIn, fOut)
    %     XeThru_No_MTI_mDopp_bulk(fIn, fOut)
        rangeDoppler_xethru(fIn, fOut_vid)
%         cutVideo(fIn, fOut_vid, beginTime, endTime(i))
        toc
    end
end

