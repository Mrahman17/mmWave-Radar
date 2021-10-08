clear; close all; clc;

fname = '04020005_1594002472.txt';
path = 'E:\COVID19 Sequential\Output\Sequence 2\rangeDoppler\77ghz\Front\labels\';
file = strcat(path,fname);

y = textread(file);

savepath = 'txts\';
% breakpoint
dlmwrite(fullfile(savepath,fname), y,'delimiter',' ');
