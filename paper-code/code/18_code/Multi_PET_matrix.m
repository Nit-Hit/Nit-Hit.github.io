%-----------------------------------------------------------------------
% Chenfei Ye updated:02/27/2018
% This script is designed for creating matrix for BIOCARDII images (volume/PET)
% Usage:
% Reset parameters before run
% Output:
% Generate both an excel file and a mat file of matrix in current folder
% Suppose that num of PET is less than nums of other modals.
% Please confirm the parameters and pathes in the beginning of this script
% Please note that LookupTable should be excel file
% ------cye7@jhu.edu
%-----------------------------------------------------------------------
clc
clear
tic;
% parameters setting

Level=5;% level of parcellation granularity
ParcellationType=2; % choose Type1 or Type2
numofMultimodal=2; % Number of multimodal MRI (default including MPRAGE/Flair/T2W/T2map/FA/Trace/PET)
sliceNum=120;


% set the input folder path
mainpath='E:\cye_code\BIOCARD_matrix\BIOCARD_PET_7subs';
Lookuptablepath = 'E:\cye_code\BIOCARD_matrix\matrix\BIOCARD_lookupTable_ko.xlsx'; % Path of LookupTable (MUST be excel file)
[num,txt,raw] = xlsread(Lookuptablepath); % read LookupTable
lsdir_sub=ls(mainpath);
lsdir_sub(1:2,:)=[];

% assign the target column of LookupTable based on granularity level
switch Level
    case 1
        if ParcellationType==1
            col=6;
        else
            col=11;
        end
    case 2
        if ParcellationType==1
            col=5;
        else
            col=10;
        end
    case 3
        if ParcellationType==1
            col=4;
        else
            col=9;
        end
    case 4
        if ParcellationType==1
            col=3;
        else
            col=8;
        end
    case 5
        if ParcellationType==1
            col=2;
        else
            col=7;
        end
end

raw(cellfun(@(x) any(isnan(x(:))), raw))=cellstr('zz_NaN'); % assign '_NaN' to NaN in lookuptable
raw(2:end,col)=strtrim(raw(2:end,col));
Uniq_col=unique(raw(2:end,col)); % filter unique parcels in target column
if  strcmp(char(Uniq_col(end)),'zz_NaN')|| strcmp(char(Uniq_col(end)),'xxxx')
    Uniq_col(end)=[];
end
Matrix=zeros(size((Uniq_col),1),numofMultimodal,size(lsdir_sub,1)); % create Matrix
ID=cellstr(lsdir_sub);

for i =[1:3,6:length(ID)] % for each subject
    PETname=strtrim(lsdir_sub(i,:));
    fixname=PETname; % select fixname of each subject name
    PETmappath=[mainpath,'\',fixname,'\',fixname,'_PET_registerd.nii'];
    Parname=ls([mainpath,'\',fixname,'\*_283Labels_M2.img']);
    Parpath=[mainpath,'\',fixname,'\',Parname];
    
    %% load each image modal and correct the NaN value
    %% PlanRaw for orientation test: load_untouch_nii
    PETfile = load_untouch_nii(PETmappath);
    PETfile.img(isnan(PETfile.img)==1) = 0;
    Parfile = load_untouch_nii(Parpath);
    Parfile.img=flipud(Parfile.img);%Make sure all images are correctly aligned before running (avoid left-right flip)
    pixvol=Parfile.hdr.dime.pixdim(2)*Parfile.hdr.dime.pixdim(3)*Parfile.hdr.dime.pixdim(4);
    
    
%         subplot(1,2,1);
%         imshow(Parfile.img(:,:,sliceNum),[])
%         subplot(1,2,2);
%         imshow(PETfile.img(:,:,sliceNum),[])
    
    
    %% load values for each parcel
    idx=zeros(length(num),1);
    for j=1:size((Uniq_col),1)
        if strcmp(char(Uniq_col(j)),'zz_NaN')
            continue
        end
        index=ismember(raw(2:end,col),char(Uniq_col(j)));
        idx=idx+j*index;
        idx_mpr=ismember(Parfile.img,find(idx==j));
        Matrix(j,1,i)=nnz(idx_mpr)*pixvol;
        PETmat=idx_mpr.*double(PETfile.img);
        Matrix(j,2,i)=sum(PETmat(:))/nnz(PETmat);
        
    end
    close all
end

%% generate result excel file
result=cell(size(lsdir_sub,1),length(Uniq_col)+1,numofMultimodal);
result(1,2:end,1)=cellstr('Volume');
result(1,2:end,2)= cellstr('PET');

%% write result cell to output in current folder
for j=1:numofMultimodal % num of modals
    result(2,2:end,j)= Uniq_col';
    result(1,1,j)= cellstr('ImageModal');
    result(2,1,j)= cellstr('Subject');
    for i=1: size(lsdir_sub,1) % num of subjects
        result(2+i,2:end,j)=num2cell(Matrix(:,j,i)');
        PETname=strtrim(lsdir_sub(i,:));
       
        fixname=PETname; % select fixname of each subject name
        result(2+i,1,j)=cellstr(fixname);
    end
    % output
    xlswrite(['Summary_Level',num2str(Level),'_Type',num2str(ParcellationType),'.xlsx'],result(:,:,j),j);
end

toc;