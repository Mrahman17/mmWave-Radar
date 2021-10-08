clear; clc; close all; 

data = '/mnt/HDD01/rspl-admin/DATASETS/110 Words ASL Fall 2020/Data/';
out = '/mnt/HDD01/rspl-admin/DATASETS/110 Words ASL Fall 2020/Output/';

subjects = dir(data);
subjects = subjects(3:end);
signPerRecord = 5; % how many different signs in a recording
for i = 1:length(subjects) % 9
        files = dir([fullfile(subjects(i).folder,subjects(i).name) '/*.bin']);
        
        if i == 7 || i == 4 % if 5 words at a time
                filenames2 = {files.name};
                for z = 1:length(filenames2)
                        temp{1,z} = filenames2{z}(1:19);
                end
                uniqs = unique(temp);
                for j = 1:length(uniqs)
                        match = strfind(filenames2,uniqs{j}); % find matches
                        idx = find(~cellfun(@isempty,match)); % find non-empty indices
                        RDC = [];
                        % concat RDCs with same names
                        for r = 1:length(idx)
                                fname = fullfile(files(idx(r)).folder,files(idx(r)).name);
                                temp2 = RDC_extract(fname);
                                RDC = [RDC temp2];
                        end
                        % divide into sub RDCs
                        numChirps = floor(size(RDC,2)/signPerRecord);
                        for r =1:signPerRecord
                                tic
                                msg = ['Processing: Subject ' int2str(i) ', File: ' int2str(j) ' of ' int2str(length(uniqs)) ', Part ' ...
                                        num2str(r) '/' num2str(signPerRecord)];   % loading message
                                disp(msg);
                                subRDC = RDC(:,(r-1)*numChirps+1:r*numChirps,:);
                                mD_Out = [out subjects(i).name '/microDoppler/' uniqs{j} '_' num2str(r) '.png'];
                                RD_Out = [out subjects(i).name '/rangeDoppler/' uniqs{j} '_' num2str(r) '.avi'];
                                DOA_Out = [out subjects(i).name '/rangeDOA/' uniqs{j} '_' num2str(r) '.avi'];
%                                 [cfar_bins] = RDC_to_rangeDopp(subRDC, RD_Out);
%                                 RDC_to_microDopp(subRDC, mD_Out, cfar_bins)
                                RDC_to_rangeDOA_AWR1642(subRDC, DOA_Out)
                                toc
                        end
                        
                end
        else
                if i == 1
                        z = 1;
                else
                        z = 1;
                end
                for j = z:length(files)
                        tic
                        msg = ['Processing: Subject ' int2str(i) ', File: ' int2str(j) ' of ' int2str(length(files))];   % loading message
                        disp(msg);
                        filename = fullfile(files(j).folder,files(j).name);
                        mD_Out = [out subjects(i).name '/microDoppler/' files(j).name(1:end-4) '.png'];
                        RD_Out = [out subjects(i).name '/rangeDoppler/' files(j).name(1:end-4) '.avi'];
                        DOA_Out = [out subjects(i).name '/rangeDOA/' files(j).name(1:end-4) '.avi'];
%                         cfar_bins = rangeDopp_AWR1642_CFAR(filename, RD_Out);
%                         microDoppler_AWR1642_CFAR(filename, mD_Out, cfar_bins)
                        RDC = RDC_extract(filename);
                        RDC_to_rangeDOA_AWR1642(RDC, DOA_Out)
                        toc
                end
        end
end

% TeamViewer is working fine right now. They reset the ID and now it's free of
% commercial tag!