clear; clc; close all; 

subject = '13 jan ridvan ademola sean akthar emre';

data = ['/media/rspl-admin/Seagate Backup Plus Drive/100sign_ASL Fall 2020/11 Nov Blake/24ghz/*.dat'];

mDout = ['/media/rspl-admin/Seagate Backup Plus Drive/100sign_ASL Fall 2020/11 Nov Blake/Output/24GHz/'];



if ~exist(mDout, 'dir')
       mkdir(mDout)
end


files = dir(data);

seqPerRecord = 1; 

filenames2 = {files.name};
for z = 1:length(filenames2)
        temp{1,z} = filenames2{z}(1:end-10);
end
uniqs = unique(temp);
for j = 1:length(uniqs)
        match = strfind(filenames2,uniqs{j}); % find matches
        idx = find(~cellfun(@isempty,match)); % find non-empty indices
        RDC = [];
        % concat RDCs with same names
        for r = 1:length(idx)
                fname = fullfile(files(idx(r)).folder,files(idx(r)).name);
                [temp2,Tsweep] = RDC_extract_Anchortech(fname);
                RDC = [RDC temp2];
        end
        % divide into sub RDCs
        numChirps = floor(size(RDC,2)/seqPerRecord);
        for r =1:seqPerRecord
                tic
                msg = ['Processing: Subject ''' subject ''', File: ' int2str(j) ' of ' int2str(length(uniqs)) ', Part ' ...
                        num2str(r) '/' num2str(seqPerRecord)];   % loading message
                disp(msg);
                subRDC = RDC(:,(r-1)*numChirps+1:r*numChirps,:);
                mD_Out = [mDout uniqs{j} '_' num2str(r) '.png'];

                RDC2MD_Anchortech(subRDC, mD_Out,Tsweep)

                toc
        end

end
