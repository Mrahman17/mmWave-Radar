clear; clc; close all; warning off;

sub = {'Emre','Mahbub','Sean','Charles'};

for j=1:length(sub)
        mD = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/*/microDoppler/77ghz/FrontNew Conference/' sub{1,j} '/labels/*.txt'];
        rD = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/*/rangeDoppler/77ghz/Front/' sub{1,j} '/labels/*.txt'];
        
        files = dir(mD);
        files2 = dir(rD);
        I_MAX = numel(files); % # of files in "files"
        I_MAX2 = numel(files2); % # of files in "files"
        
        
        for i = 1:I_MAX   % for the first 20 iteration
                msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX)]);   % loading message
                disp(msg);
                fName = files(i).name;
                [foo1, name, foo2] = fileparts(fName);
                fIn = fullfile(files(i).folder, files(i).name);
                seq = num2str(fName(4));
                
                outmD = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' num2str(seq) '/microDoppler/77ghz/FrontNew Conference/' sub{1,j} '/labels binary/'];
                fOut = strcat(outmD, name, '_binary.txt');
                
                y = textread(fIn);
                ybin = y ~= 0;
                dlmwrite(fOut, ybin,'delimiter',' ');
        end
        
        for i = 1:I_MAX2   % for the first 20 iteration
                msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX)]);   % loading message
                disp(msg);
                fName = files(i).name;
                [foo1, name, foo2] = fileparts(fName);
                fIn = fullfile(files(i).folder, files(i).name);
                seq = num2str(fName(4));
                
                outrD = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' num2str(seq) '/rangeDoppler/77ghz/Front/' sub{1,j} '/labels binary/'];
                fOut = strcat(outrD, name, '_binary.txt');
                
               y = textread(fIn);
               ybin = y ~= 0;
               dlmwrite(fOut, ybin,'delimiter',' ');
                
        end
end