%-----------------------------------------------------------------------
% Chenfei Ye 03/25/2017
% This script is designed to intensity-nomalize FLAIR of BIOCARD
% Please make sure the same orientation!
% method reference https://www.ncbi.nlm.nih.gov/pubmed/21873031
% ------cye7@jhu.edu
clc
clear
mainfolder='C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\BIOCARDII_multimodal_90subs';
dirs=dir(mainfolder ); % ·µ»ØÒ»¸östruct
dircell=struct2cell(dirs)' ;
subfolder=dircell(:,1) ;
subfolder(1:2,:)=[];

for i = 1:length(subfolder)
    mprage_path=[mainfolder,filesep,char(subfolder(i)),filesep,'moWIPMPRAGESENSE.nii'];
    %     if exist([mainfolder,filesep,char(subfolder(i)),filesep,'c5moWIPMPRAGESENSE.nii'])
    %         continue
    %     end
    %% segmentation for Flair
    rawFlair_path=[mainfolder,filesep,char(subfolder(i)),filesep,'WIPFLAIRSENSE.nii'];
    
    
    %     %% coregistrate
    %     jobs{1}.spm.spatial.coreg.estwrite.ref ={[mprage_path,',1']};
    %     jobs{1}.spm.spatial.coreg.estwrite.source ={[rawFlair_path,',1']};
    %     jobs{1}.spm.spatial.coreg.estwrite.other ={[rawFlair_path,',1']};
    %     jobs{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    %     jobs{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    %     jobs{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    %     jobs{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    %     jobs{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
    %     jobs{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    %     jobs{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    %     jobs{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    %
    %     spm_jobman('run',jobs);
    %     clear jobs
    
    
    
    
    % skull stripping of Flair
    rflair_path=[mainfolder,filesep,char(subfolder(i)),filesep,'rWIPFLAIRSENSE.nii'];
    Flair=load_untouch_nii(rflair_path);
    Flair.img(isnan(Flair.img))=0;
    
    mask_ls=ls([mainfolder,filesep,char(subfolder(i)),filesep,'*7labels.hdr']);
    mask_path=[mainfolder,filesep,char(subfolder(i)),filesep,mask_ls];
    mask= load_untouch_nii(mask_path);
    mask.img=flipud(mask.img);
    
    sFlair=Flair;
    sFlair.img=Flair.img;
    sFlair.img(mask.img==5)=0;
    sFlair.img(mask.img==1)=0;
    sFlair.img(mask.img==6)=0;
    sFlair.img(mask.img==0)=0;
    %save_untouch_nii(sFlair , [mainfolder,filesep,char(subfolder(i)),filesep,'srWIPFLAIRSENSE.nii']);
    
    % bias correction after outlier moving (only keep LV,WM,GM, idx=2,3,4)
    srflair_path=[mainfolder,filesep,char(subfolder(i)),filesep,'srWIPFLAIRSENSE.nii'];
    msrflair_path=[mainfolder,filesep,char(subfolder(i)),filesep,'msrWIPFLAIRSENSE.nii'];
    
    %system(['N4BiasFieldCorrection -d 3 -i "',srflair_path,'" -s 4 -o "',msrflair_path,'"']);
    
    % read flair after bias correction
    msrflair= load_untouch_nii(msrflair_path);
    
    % intensity normalization
    GMimg=zeros(size(mask.img));
    GMimg(mask.img==3)=1;
    GM_img=double(msrflair.img).*GMimg;
    GM_vec=GM_img(GM_img~=0);
    lower_bound=prctile(GM_vec,2.5);
    upper_bound=prctile(GM_vec,97.5);
    GM_mean=mean(GM_vec(GM_vec<upper_bound&GM_vec>lower_bound));
    
    
    WMimg=zeros(size(mask.img));
    WMimg(mask.img==2)=1;
    WM_img=double(msrflair.img).*WMimg;
    WM_vec=WM_img(WM_img~=0);
    lower_bound=prctile(WM_vec,2.5);
    upper_bound=prctile(WM_vec,97.5);
    WM_mean=mean(WM_vec(WM_vec<upper_bound&WM_vec>lower_bound));
    
    Global_mean=0.5*(GM_mean+WM_mean);
    ratio=1/Global_mean;
    msrflair.img=msrflair.img*ratio;
    
    save_untouch_nii(msrflair , [mainfolder,filesep,char(subfolder(i)),filesep,'nmsrWIPFLAIRSENSE.nii']);
    
end

