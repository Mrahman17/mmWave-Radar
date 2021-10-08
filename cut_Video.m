clc; clear; close all;

main = '/mnt/HDD01/rspl-admin/DATASETS/110 Words ASL Fall 2020/Output/';

subjects = dir(main);
subjects = subjects(3:end);

for s = 1:length(subjects)
        
        labelpath = [main subjects(s).name '/rangeDoppler/labels/*.txt'];
        labels = dir(labelpath);
        vidpath = [main subjects(s).name '/rangeDOA/*.avi'];
        vids = dir(vidpath);
        cutpath = [main subjects(s).name '/rangeDOA/Cut/']; 
        if s ==4
                z = 1;
        else 
                z = 1;
        end
        for i = z:length(labels)
              fname = labels(i).name(1:end-4);
              match = strfind({vids.name},fname);
              idx = find(~cellfun(@isempty,match)); % find non-empty indices
              fIn = fullfile(vids(idx).folder,vids(idx).name);
              y = load(fullfile(labels(i).folder,labels(i).name));
              mask = logical(y);    %(:).' to force row vector
              starts = strfind([false, mask], [0 1]);
              stops = strfind([mask, false], [1 0]);
              if length(starts) ~= length(stops)
                      stops = [stops 570];
              end
              for j = 1:length(starts)
                      msg = ['Processing: Subject ' int2str(s) ', File: ' int2str(i) ' of ' int2str(length(labels)) ', Part ' ...
                                        num2str(j) '/' num2str(length(starts))];   % loading message
                      disp(msg);
                      label = mode(y(starts(j):stops(j)));
                      fOut = [cutpath fname '_' num2str(j) '_' num2str(label)];
                      cutVideo_label(fIn, fOut, starts(j), stops(j))
              end
        end
        
        
        
        
        
        
end












