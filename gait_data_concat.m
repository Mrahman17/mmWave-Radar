clc; clear all; close all;
% fIn_1='C:\Users\uarspl\Desktop\77ghz_data\Sub_Dr_Martelli\human_walk_Martelli_2_Raw_0.bin';
% fIn_2='C:\Users\uarspl\Desktop\77ghz_data\Sub_Dr_Martelli\human_walk_Martelli_2_Raw_1.bin';
 fIn_3='C:\Users\uarspl\Desktop\77ghz_data\Sub_Dr_Martelli\martelli_4_1_min_Raw_0.bin';
 fIn_4='C:\Users\uarspl\Desktop\77ghz_data\Sub_Dr_Martelli\martelli_4_1_min_Raw_1.bin';
% fIn_5='C:\Users\uarspl\Desktop\77ghz_data\Sub_Dr_Martelli\human_walk_Martelli_2_Raw_4.bin';

RDC1=RDC_extract(fIn_3);
RDC2=RDC_extract(fIn_4);
% RDC3=RDC_extract(fIn_3);
% RDC4=RDC_extract(fIn_4);
% RDC5=RDC_extract(fIn_5);
Final_RDC=cat(2,RDC1,RDC2);
fOut='human_walk_Martelli_2_Raw_0';
gait_RDC_to_microDopp( Final_RDC, fOut )
