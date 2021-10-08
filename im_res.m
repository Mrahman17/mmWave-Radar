clc; clear all; close all;

root='/home/rspl-admin/Data/asl/testB';

files=dir(root);
save_dir='/home/rspl-admin/Data/asl/testB_64/';
   
         if 2~=exist(save_dir,'dir')
                mkdir(save_dir);
        end
for ii=1:size(files,1)-2
        im=strcat(files(ii+2).folder,'/',files(ii+2).name);
        img=imread(im);
        res_img=imresize(img,[256 256]);
        savename=strcat(save_dir,files(ii+2).name);
        imwrite(res_img,savename);

end