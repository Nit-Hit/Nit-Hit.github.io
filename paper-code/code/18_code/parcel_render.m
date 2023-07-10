%-----------------------------------------------------------------------
% Chenfei Ye 03/03/2018
% This script is designed to render parcel
% Template is STEJUD
% NOTE£ºwhen open in MRIcroN, set overlay transparency to additive, and
% change range to [1,3]!!
% ------cye7@jhu.edu
clc
clear
%% change below part
LevelType = 2; % 1 for Type 1, 2 for Type 2
parcel_path='E:\cye_code\BIOCARD_matrix\L5T2_noBrainstem\Vol';
%%

outbrain_label=[0,248:251,254];
all_label=[1:283];
brain_label=setdiff(all_label,outbrain_label,'stable' );
load([parcel_path,filesep,'stat_parcel.mat']);
[~,~,lookuptable]=xlsread(['E:\cye_code\BIOCARD_matrix\matrix\Structures_removed_T1combine_LV.xlsx'],'All'); % read excel matrix
Label283= load_untouch_nii('E:\cye_code\BIOCARD_matrix\brain_template\283L.hdr');
mask=ones(size(Label283.img));
for i =outbrain_label
    mask(Label283.img==i)=6;
end

for i =brain_label
    mask(Label283.img==i)=0;
end

if stat_parcel.num005~=0
    dots005=stat_parcel.p005(:,1);
    if LevelType==1
        [Lia,Locb] = ismember(lookuptable(:,1),dots005);
    elseif LevelType==2
        idx=cellfun(@(x) any(isnan(x(:))), lookuptable(:,2)); % find NaN in lookuptable
        lookuptable=lookuptable(idx==0,:);% remove NaN in lookuptable
        [Lia,Locb] = ismember(lookuptable(:,2),dots005);
    end
    list_p005=find(Lia==1);
    for i =list_p005'
        mask(Label283.img==i)=2;
    end
end

if stat_parcel.numfdr~=0
    dots_fdr=stat_parcel.fdr(:,1);
    if LevelType==1
        [Lia,Locb] = ismember(lookuptable(:,1),dots_fdr);
    elseif LevelType==2
        [Lia,Locb] = ismember(lookuptable(:,2),dots_fdr);
    end
    list_fdr=find(Lia==1);
    for i =list_fdr'
        mask(Label283.img==i)=4;
    end
end

Label283.img=mask;
save_untouch_nii(Label283 , [parcel_path,filesep,'PBA.hdr']);
