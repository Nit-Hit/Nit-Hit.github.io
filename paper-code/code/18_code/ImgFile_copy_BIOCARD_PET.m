%-----------------------------------------------------------------------
% Chenfei Ye 03/29/2018
% This script is designed for moving BIOCARDII 51 subject images (mpr/PET)  to a new folder
% Usage:
% Reset parameters before run
% choose the PET folder, and Parcellation map folder
% Suppose that num of PET is less than nums of other modals.
% Please confirm the parameters and pathes in the beginning of this script
% ------cye7@jhu.edu
%-----------------------------------------------------------------------
clc
clear
tic;

% set the input folder path
PETpath = 'H:\Share\BIOCARDII_PET_cor2'; % Folder path of BIOCARDII PET images
Parmappath1 = 'H:\MT_jhu\BIOCARDII_MPRAGE\Results2'; % Folder path of BIOCARDII parcellation maps
Parmappath2 = 'H:\MT_jhu\BIOCARDII_MPRAGE\Results'; % Folder path of BIOCARDII parcellation maps
Lookuptablepath = 'E:\cye_code\BIOCARD_matrix\matrix\BIOCARD_lookupTable_ko.xlsx'; % Path of LookupTable (MUST be excel file)

[num,txt,raw] = xlsread(Lookuptablepath); % read LookupTable
lsdir_PET=ls([PETpath,'\*PET_registerd.nii']); % select PET images in PET folder
% lsdir_Par=ls(Parmappath); % select parcellation maps in parcellation folder
mkdir('BIOCARD_PET_51subs');




for i = 1:size(lsdir_PET,1) % for each subject
    PETname=strtrim(lsdir_PET(i,:));
    id=strfind(PETname,'_');
    id_first=id(1);
    fixname=PETname(1:(id_first-1)); % select fixname of each subject name
    %fixname=strtrim(lsmat(i,:));
    mkdir('BIOCARD_PET_51subs',fixname);
    Parmapfolder=ls([Parmappath1,'\*',fixname,'*']); % select parcellation map folder of each subject
    if isempty(Parmapfolder)
        Parmapfolder=ls([Parmappath2,'\*',fixname,'*']); % select parcellation map folder of each subject
        Parmappath=Parmappath2;
    else
        Parmappath=Parmappath1;
    end
    
    PETmappath=[PETpath,'\',fixname,'_PET_registerd.nii'];
    Parname=ls([Parmappath,'\',Parmapfolder,'\*_283Labels_M2.img']);
    Parname2=ls([Parmappath,'\',Parmapfolder,'\*_283Labels_M2.hdr']);
    Parpath=[Parmappath,'\',Parmapfolder,'\',Parname];
    Parpath2=[Parmappath,'\',Parmapfolder,'\',Parname2];
    
    
    
    %% load each image modal and correct the NaN value
    
    copyfile(PETmappath,[cd,'\BIOCARD_PET_51subs\',fixname]);
    copyfile(Parpath,[cd,'\BIOCARD_PET_51subs\',fixname]);
    copyfile(Parpath2,[cd,'\BIOCARD_PET_51subs\',fixname]);
end


toc;