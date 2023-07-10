%-----------------------------------------------------------------------
% Chenfei Ye 02/07/2017
% This script is designed for BIOCARD2 rs-fmri data loading from z_cor.txt
% functions:
% ------cye7@jhu.edu
clc
clear
[num, ~, raw]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type2_filtered_T1combine_LV_noflip.xlsx','Sheet1'); % read excel matrix
fmri_path=['J:\BIOCARD_fMRI\Results'];
fmri_dir=dir(fmri_path);
fmri_dircell=struct2cell(fmri_dir)' ;
fmri_names=fmri_dircell(:,1) ;
fmri_names(1:2,:)=[];
fmri_ID=cellfun(@(x) strsplit(x,'_'),fmri_names,'UniformOutput',false);
fmri_ID_mid=cellfun(@(x) char(x(2)),fmri_ID,'UniformOutput',false);
fmri_ID_str=char(fmri_ID_mid);

raw_name=raw(3:end,1);

[C,ia,ib]=intersect(raw_name,fmri_ID_str,'stable');

for i = 1:length(raw_name)
    z_cor_path=fullfile(fmri_path,char(fmri_names(ib(i),:)),'z_cor.txt');
    if i ==1
        z_cor_var = import_z_cor(z_cor_path,1,1);
        num_var=length(z_cor_var)-1;
        z_cor=zeros(num_var,num_var,length(raw_name));
    end
    z_cor(:,:,i) =  import_z_cor_num(z_cor_path);
end
z_cor_var(:,1)=[];
z_cor_var_str=strtrim(char(z_cor_var));
z_cor_var=cellstr(z_cor_var_str);
save('z_cor_var','z_cor_var');
save('z_cor','z_cor');
