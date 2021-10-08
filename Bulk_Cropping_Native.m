clc; clear; close all; warning off
saveColor = 'C:\Users\mrahman17\Desktop\Xethru_ASL\output_xethru\microDoppler No MTI\Side\Cropped\Colored\';
saveGray = 'C:\Users\mrahman17\Desktop\Xethru_ASL\output_xethru\microDoppler No MTI\Side\Cropped\Gray\';
saveMatrix = 'C:\Users\mrahman17\Desktop\Xethru_ASL\output_xethru\microDoppler No MTI\Side\Cropped\Matrix\';
datapath = 'C:\Users\mrahman17\Desktop\Xethru_ASL\output_xethru\microDoppler No MTI\Side\';

Folder_name = {'You';'Hello';'Walk';'Drink';'Friend';'Knife';'Well';'Car';'Engineer';'Mountain';'Lawyer';'Hospital';'Health';'Earthquake';'Breath';'Help';'Push';'Go';'Come';'Write'};
Folder_name2 = repelem(Folder_name,3,3);
% create folders
for i=1:length(Folder_name)
    if ~exist([saveColor Folder_name{i}], 'dir')
       mkdir([saveColor Folder_name{i}])
       mkdir([saveGray Folder_name{i}])
       mkdir([saveMatrix Folder_name{i}])
    end
end
pattern = strcat(datapath, '*.fig');    % file pattern
% pattern = strcat(datapath, '*.png');    % file pattern
files = dir(pattern);

pattern2 = strcat(datapath, '*.mat');    % file pattern
files2 = dir(pattern2);

I_MAX = numel(files); % # of files in "files" 
m = 200; % set 1 value below th desired, cropping dimensions - width - 168
n = 450; % set 1 value below th desired, cropping dimensions - height - 441

for ii =52:I_MAX % last one is not an image file. although first 2 are also not image, but we are taking care of that in indexing
    fig = strcat(datapath,files(ii).name);
    matfile = strcat(datapath,files2(ii).name);
    
    figfile = openfig(fig);
    set(gcf, 'units','normalized','outerposition',[.1 .2 .7 .65]);
%     image = imread(fig);
    
    F = getframe(gca);
    [img,~] = frame2im(F);
    colormap(gray)
    Fgray = getframe(gca);
    [imgray,~] = frame2im(Fgray);
    
    load(matfile);
    ratioX = size(sx_scaled,2)/size(img,2);
%     ratioX = size(sx_scaled,2)/size(image,2);
    stepsize = m*ratioX; 
    
    for jj=1:3
        msg = strcat('Crop (', int2str(ii),'/',int2str(I_MAX), ') |  ',...
            int2str(jj),'. image (',Folder_name2(ii,jj),') ','File: ',files(ii).name);
        disp(msg)
        name_color = strcat(saveColor, Folder_name2(ii,jj),'\', files(ii).name(1:end-4), '_', int2str(jj),'.png');
        name_gray = strcat(saveGray, Folder_name2(ii,jj),'\', files(ii).name(1:end-4), '_', int2str(jj),'.png');
        name_matrix= strcat(saveMatrix, Folder_name2(ii,jj),'\', files(ii).name(1:end-4), '_', int2str(jj),'.mat');
        imshow(img)
        h = imrect(gca,[m*jj 30 m n]);
        position = wait(h); %[left to right, top to bottom, x length, y length]
        delete(h); 
        cropColor = imcrop(img, position);
        cropGray = imcrop(imgray, position);
        sx_cropped = sx_scaled(:, position(1)*ratioX:position(1)*ratioX+stepsize);
        save(name_matrix{1,1}, 'sx_cropped');
        imwrite(cropColor,name_color{1,1}) %change jj with the outer loop index while processing multiple images
        imwrite(cropGray,name_gray{1,1}) %change jj with the outer loop index while processing multiple images

    end
    close all
    fclose('all');
end