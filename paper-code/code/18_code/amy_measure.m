%-----------------------------------------------------------------------
% Chenfei Ye 02/08/2017
% This script is designed for calculating amyloid measture for X axis
% ------cye7@jhu.edu
function amyloid = amy_measure(Parcel_DVRref,amyType)
% if LevelType==5.2
%     [num_vol, txt_vol, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type2_filtered_T1combine_LV.xlsx','Sheet1');
%     [num_PET, txt_PET, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type2_filtered_T1combine_LV.xlsx','Sheet7');
% else
%     [num_vol, txt_vol, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type1_filtered_T1combine_LV_flair2.xlsx','Sheet1');
%     [num_PET, txt_PET, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type1_filtered_T1combine_LV_flair2.xlsx','Sheet7');
% end
[num_vol, txt_vol, ~]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type1_filtered_T1combine_LV_noflip.xlsx','Sheet1');
[num_PET, txt_PET, ~]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type1_filtered_T1combine_LV_noflip.xlsx','Sheet7');

var_vol=txt_vol(2,2:end);
var_PET=txt_PET(2,2:end);
[~, txt_283L, ~]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\BIOCARD_lookupTable_ko.xlsx','Sheet1');
txt_283L(1,:)=[];
% if LevelType==5.2
%     cortocal=txt_283L(Parcel_DVRref,7);
% else
%     cortocal=txt_283L(Parcel_DVRref,2);
% end
cortocal=txt_283L(Parcel_DVRref,2);

idx_vol=ismember(var_vol,cortocal);
idx_PET=ismember(var_PET,cortocal);

Vol_lobe=sum(num_vol(:,idx_vol),2);
PET_lobe=sum((num_vol(:,idx_vol)).*(num_PET(:,idx_PET)),2);
Parcel_DVR = PET_lobe./Vol_lobe;

switch amyType
    case 1
        amyloid=PET_lobe;
    case 2
        amyloid=Parcel_DVR;
end