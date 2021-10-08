clear; clc; close all; warning off;
seq = '3';
type = 'train';
DATA_DIR = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/microDoppler/77ghz/FrontNew Conference/Emre/labels/' type '/*.txt'];
VID_DIR = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/rangeDoppler/77ghz/Front/Emre/'];
IM_DIR =['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/microDoppler/77ghz/FrontNew Conference/Emre/'];
env_dir = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/microDoppler/77ghz/FrontNew Conference/Emre/envelopes/'];
files = dir(DATA_DIR);
filesvid = dir(VID_DIR);
% filesim = dir(IM_DIR);

dest_vid = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/rangeDoppler/77ghz/Front/Emre/' type];
dest_im = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/microDoppler/77ghz/FrontNew Conference/Emre/' type];
dest_env = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
        '/microDoppler/77ghz/FrontNew Conference/Emre/' type];

I_MAX = numel(files); % # of files in "files" 
   
for i = 1:I_MAX   % for the first 20 iteration

    msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX)]);   % loading message
    disp(msg);
    fName = files(i).name(1:end-4);
    fnamevid =[VID_DIR fName '.avi'];
    fnameim =[IM_DIR fName '.png'];
    fnameenv =[env_dir fName '.txt'];
    
    movefile(fnamevid, dest_vid)
    movefile(fnameim, dest_im)
    movefile(fnameenv, dest_env)
end

