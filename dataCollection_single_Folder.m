clear; clc; close all; warning off;
DATA_DIR='C:\Users\uarspl\Desktop\2_sensor_exp_Feb_9\';
OUT_DIR = 'C:\Users\uarspl\Desktop\Output_2_sensor_exp_Feb_9\';   
if 2~=exist(OUT_DIR,'dir')
                mkdir(OUT_DIR);
 end
pattern = strcat(DATA_DIR, '*.bin');    % file pattern
files = dir(pattern);

% w = waitbar(0);

I_MAX = numel(files); % # of files in "files"

for i = 1: I_MAX  % for the first 20 iteration
        tic
        msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX)]);   % loading message
        %     waitbar(i/I_MAX, w, msg);
        disp(msg);
        fName = files(i).name;
        [foo1, name, foo2] = fileparts(fName);
        fIn = fullfile(files(i).folder, files(i).name);
        fOut = strcat(OUT_DIR, name, '.png');
        %fOut_vid = strcat(OUT_DIR, name, '.avi');

        microDoppler_AWR1642_bulk_BPM(fIn, fOut)
        toc
end
%end
% close(w);
