clear; clc; close all; warning off;

sub = {'Sean','Charles'};

for j=2:length(sub)
        data = ['/media/rspl-admin/Seagate Backup Plus Drive/COVID19 Sequential/' sub{1,j} '/77ghz/Front/*.bin'];
        
        files = dir(data);
        I_MAX = numel(files); % # of files in "files"
        
        for i = 10:I_MAX   % for the first 20 iteration
                tic
                msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX)]);   % loading message
                %     waitbar(i/I_MAX, w, msg);
                disp(msg);
                fName = files(i).name;
                [foo1, name, foo2] = fileparts(fName);
                fIn = fullfile(files(i).folder, files(i).name);
                seq = num2str(fName(4));
                spect_out =['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
                        '/microDoppler/77ghz/FrontNew Conference/' sub{1,j} '/'];
                rd_out = ['/mnt/HDD01/rspl-admin/DATASETS/COVID19 Sequential/Output/Sequence ' seq ...
                        '/rangeDoppler/77ghz/Front/' sub{1,j} '/'];
                fOut = strcat(spect_out, name, '.png');
                fOut_vid = strcat(rd_out, name, '.avi');
                %         seq =
                %     datToImage_Anchortek_No_MTI(fIn, fOut, fName);
                %     datToImageV1( fIn, fOut, fName )
                %     datToImage_77( fIn, fOut, fName );
                %     datToImage_matrix(fIn, fOut, fName );
                %     datToImage_77_MTI( fIn, fOut, fName );
                %     rangeDoppler_Anchortech(fIn, fOut_vid, fName);
                %     debug_CVD(fIn, fOut, fName);
                %     Xethru_spec(fIn, fOut, fName);
                %     rangeDopp_Video(fIn, fOut_vid, fName);
                %     range_Dopp_apart(fIn, fOut_vid, fName);
                %     optical_flow_auto(fIn, fOut, fName);
                %     PSD_auto(fIn, fOut, fName);
                %     vel_est_77(fIn, fOut, fName);
                %     opt_flow_velocity(fIn, fOut, fName);
                %     opticalFlow_77_20sec(fIn, fOut, fName);
                microDoppler_AWR1642_bulk_BPM(fIn, fOut)
                rangeDopp_AWR1642(fIn, fOut_vid)
                %             spect_to_OF(fIn, fOut)
                %             RD_OF_RadarConf(fIn,fOut,fName)
                %         datToImage_Anchortech(fIn, fOut)
                toc
        end
end