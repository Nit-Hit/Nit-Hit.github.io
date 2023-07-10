%-----------------------------------------------------------------------
% Chenfei Ye 06/23/2017
% This script is designed for comparing similarity between different
% images, except for T1-vol
% The aim is to validate T2map iron deposition hypothesis
% ------cye7@jhu.edu
clc
clear
close all

img_modal_PET=7;   % (7 for PET)
img_modal_G2=6;   % (4 for T2map, 5 for FA, 6 for trace)
ParcelTestType=false; % False for nothing, True for correlation of parcel and amyloid, and parcel ttest
LevelType=5; % Choose parcellation level, 4 or 4.2 or 5 or 5.2. X.2 means type 2
SaveType=false; % save file or not
amyType=2; % Amyloid axis: 1 for lobe, 2 for DVR
Parcel_DVRref=[1:22,27:44,51:56,61:70];% reference parcels for DVR threshold
matrix_path='C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\';

%% calculate amyloid measture for X axis
amyloid = amy_measure(Parcel_DVRref,amyType,LevelType);
HighAmyIndex=find(amyloid>=1.06); % index of subjects with high amyloid
LowAmyIndex=find(amyloid<1.06);  % index of subjects with low amyloid
%% for PET
switch LevelType
    case 5
        [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type1_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal_PET)]); % read excel matrix
    case 5.2
        [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type2_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal_PET)]); % read excel matrix
    case 4.2
        [num, ~, raw]=xlsread([matrix_path,'Summary_Level4_Type2_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal_PET)]); % read excel matrix
end
raw_var=raw(2,2:end);
ID=raw(3:end,1);
[num,Coeff]=adjustment(num,ID,LowAmyIndex);
if ParcelTestType
    stat_parcel=par_test(num,raw_var,amyloid,size(num,2),HighAmyIndex,LowAmyIndex,ID);
end
[Highmap_PET,High_corP]=corrcoef(num(HighAmyIndex,:));
Parcel_mean_PET=mean(num(HighAmyIndex,:),1);
clear num;
clear raw;

%% for G2
switch LevelType
    case 5
        [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type1_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal_G2)]); % read excel matrix
    case 5.2
        [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type2_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal_G2)]); % read excel matrix
    case 4.2
        [num, ~, raw]=xlsread([matrix_path,'Summary_Level4_Type2_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal_G2)]); % read excel matrix
end
raw_var=raw(2,2:end);
ID=raw(3:end,1);
[num,Coeff]=adjustment(num,ID,LowAmyIndex);
if ParcelTestType
    stat_parcel=par_test(num,raw_var,amyloid,size(num,2),HighAmyIndex,LowAmyIndex,ID);
end
[Highmap_G2,High_corP]=corrcoef(num(HighAmyIndex,:));
Parcel_mean_G2=mean(num(HighAmyIndex,:),1);
clear num;
clear raw;
%% compare similarity of parcel
corr(Parcel_mean_PET',Parcel_mean_G2')
%% compare similarity of Rmap
p_PET_triu=triu(Highmap_PET,1);p_G2_triu=triu(Highmap_G2,1);
p_vec_PET_triu=p_PET_triu(:); p_vec_G2_triu=p_G2_triu(:);
p_vec_PET_triu(p_vec_PET_triu==0)=[];p_vec_G2_triu(p_vec_G2_triu==0)=[];
corr(p_vec_PET_triu,p_vec_G2_triu)