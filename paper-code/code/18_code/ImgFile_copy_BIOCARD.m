%-----------------------------------------------------------------------
% Chenfei Ye updated:02/27/2018
% This script is designed for moving BIOCARDII images
% (mpr/FLAIR/T2w/T2map/FA/Trace/PET)  to a new folder
% Usage:
% Reset parameters before run
% choose the main folder (mpr/rawFLAIR/FLAIR/T2w/T2map), DTI folder, PET folder, and Parcellation map folder
% Suppose that num of PET is less than nums of other modals.
% Please confirm the parameters and pathes in the beginning of this script
% ------cye7@jhu.edu
%-----------------------------------------------------------------------
clc
clear
tic;

% set the input folder path
sMRIpath= 'H:\Share\BIOCARDII'; %  Main folder path of BIOCARDII (mpr/FLAIR/T2w/T2map)
DTIpath = 'H:\MT_jhu\BIOCARDII_DTI'; % Folder path of BIOCARDII DTI images
PETpath = 'H:\Share\BIOCARDII_PET_cor'; % Folder path of BIOCARDII PET images
Parmappath = 'H:\MT_jhu\BIOCARDII_MPRAGE\Results'; % Folder path of BIOCARDII parcellation maps
Lookuptablepath = 'E:\cye_code\BIOCARD_matrix\matrix\BIOCARD_lookupTable_ko.xlsx'; % Path of LookupTable (MUST be excel file)

[num,txt,raw] = xlsread(Lookuptablepath); % read LookupTable
lsdir_PET=ls([PETpath,'\*PET_registerd.nii']); % select PET images in PET folder 
lsdir_sMRI=ls(sMRIpath); % select mpr/FLAIR/T2w/T2map images in main folder 
lsdir_DTI=ls(DTIpath); % select DTI images in DTI folder 
lsdir_Par=ls(Parmappath); % select parcellation maps in parcellation folder 
if min([size(lsdir_PET,1),size(lsdir_sMRI,1),size(lsdir_DTI,1),size(lsdir_Par,1)])~=size(lsdir_PET,1)
    error('Suppose that num of PET should be less than nums of other modals');
end

 mkdir('BIOCARD_multimodal_90subs');




for i = 1:size(lsdir_PET,1) % for each subject
    PETname=strtrim(lsdir_PET(i,:));
    id=strfind(PETname,'_');
    id_first=id(1);
    fixname=PETname(1:(id_first-1)); % select fixname of each subject name
    %fixname=strtrim(lsmat(i,:));
    mkdir('BIOCARD_multimodal_90subs',fixname);
    sMRIfolder=ls([sMRIpath,'\*',fixname,'*']); % select main folder of each subject 
    DTIfolder=ls([DTIpath,'\*',fixname,'*']); % select DTI folder of each subject 
    Parmapfolder=ls([Parmappath,'\*',fixname,'*']); % select parcellation map folder of each subject 
    if isempty(sMRIfolder)||isempty(DTIfolder)||isempty(Parmapfolder)
        disp(['some modal Lack for ',fixname]);
        continue
    end
    sub2_path=dir([sMRIpath,'\',sMRIfolder]); %return subdirectory info of main folder
    
    %% make sure the name and organization below is correct
    mprimage=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*MPRAGE']);
    flairimage=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*FLAIR']);
    T2Wimage=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*T2AX']);
    RECfile=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*PAR_REC_files']);
    
    mprpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',mprimage,'\moWIPMPRAGESENSE.nii'];
    flairpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',flairimage,'\rmWIPFLAIRSENSE.nii'];
    rawflairpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',flairimage,'\WIPFLAIRSENSE.nii'];
    T2Wpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',T2Wimage,'\rmWIPSkinnyT2AXSENSEA.nii'];
    T2mappath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',RECfile,'\resources\PAR_REC\files\T2_map.nii'];
    rT2mappath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',RECfile,'\resources\PAR_REC\files\rT2_map.nii'];
    b0path=[DTIpath,'\',DTIfolder,'\QcDtiMap\rmRefB0.nii'];
    FAmappath=[DTIpath,'\',DTIfolder,'\QcDtiMap\rFaMap.img'];
    FAmappath2=[DTIpath,'\',DTIfolder,'\QcDtiMap\rFaMap.hdr'];
    Tracepath=[DTIpath,'\',DTIfolder,'\QcDtiMap\rTrace.img'];
    Tracepath2=[DTIpath,'\',DTIfolder,'\QcDtiMap\rTrace.hdr'];
    PETmappath=[PETpath,'\',fixname,'_PET_registerd.nii'];
    Parname=ls([Parmappath,'\',Parmapfolder,'\*_283Labels_M2.img']);
    Parname2=ls([Parmappath,'\',Parmapfolder,'\*_283Labels_M2.hdr']);
    Parpath=[Parmappath,'\',Parmapfolder,'\',Parname];
    Parpath2=[Parmappath,'\',Parmapfolder,'\',Parname2];
    L7=ls([Parmappath,'\',Parmapfolder,'\*_7Labels.img']);
    L7hdr=ls([Parmappath,'\',Parmapfolder,'\*_7Labels.hdr']);
    ParL7path=[Parmappath,'\',Parmapfolder,'\',L7];
    ParL7hdrpath2=[Parmappath,'\',Parmapfolder,'\',L7hdr];
    
    %% load each image modal and correct the NaN value
    
    
%     copyfile(mprpath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(flairpath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(rawflairpath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(T2Wpath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(T2mappath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(FAmappath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(FAmappath2,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(Tracepath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(Tracepath2,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(PETmappath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(Parpath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(Parpath2,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(b0path,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(ParL7path,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(ParL7hdrpath2,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
     copyfile(T2mappath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
%     copyfile(rT2mappath,[cd,'\BIOCARD_multimodal_90subs\',fixname]);
   % delete([cd,'\BIOCARDII_multimodal_95subs\',fixname,'\rT2_map.nii']);

end


toc;