%-----------------------------------------------------------------------
% Chenfei Ye updated:03/27/2017
% Update: add left-right flip for parcellation map
% This script is designed for creating matrix for BIOCARDII/ADNI images (only FLAIR!!!!!!!!)
% Usage:
% Reset parameters before run
% choose the main folder (mpr/FLAIR/T2w/T2map), DTI folder, PET folder, and Parcellation map folder
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
ParcellationType=1; % choose Type1 or Type2


% set the input folder path
mainpath= 'D:\Share\HAN'; %  Main folder path of FLAIR
Lookuptablepath = 'C:\Users\susumulab\Desktop\BIOCARD_test\BIOCARD_lookupTable_ko.xlsx'; % Path of LookupTable (MUST be excel file)
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

[num,txt,raw] = xlsread(Lookuptablepath); % read LookupTable
lsdir=ls(mainpath); % select mpr/FLAIR/T2w/T2map images in main folder 
lsdir(1:2,:)=[];


raw(cellfun(@(x) any(isnan(x(:))), raw))=cellstr('zz_NaN'); % assign '_NaN' to NaN in lookuptable
raw(2:end,col)=strtrim(raw(2:end,col));
Uniq_col=unique(raw(2:end,col)); % filter unique parcels in target column
if  strcmp(char(Uniq_col(end)),'zz_NaN')|| strcmp(char(Uniq_col(end)),'xxxx')
    Uniq_col(end)=[];
end
Matrix=zeros(size((Uniq_col),1),size(lsdir,1)); % create Matrix


for i = 1:size(lsdir,1) % for each subject
 
    
    %% make sure the name and organization below is correct
    Parname=ls([mainpath,'\',lsdir(i,:),'\*PM.img']);
    Parpath=[mainpath,'\',lsdir(i,:),'\',Parname];
    flairpath=[mainpath,'\',lsdir(i,:),'\nrmflair.nii'];

    
    
    %% load each image modal and correct the NaN value

    flairfile = load_untouch_nii(flairpath);
    flairfile.img(isnan(flairfile.img)==1) = 0;    
    Parfile = load_untouch_nii(Parpath);
    
    %% Make sure all images are correctly aligned before running (avoid left-right flip)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %Parfile.img=flipud(Parfile.img); %
    
    
    %% load values for each parcel
    idx=zeros(length(num),1);
    for j=1:size((Uniq_col),1)
        if strcmp(char(Uniq_col(j)),'zz_NaN')
            continue
        end
        index=ismember(raw(2:end,col),char(Uniq_col(j)));
        idx=idx+j*index;
        idx_mpr=ismember(Parfile.img,find(idx==j));
        
        if ~all(size(double(flairfile.img))==size(idx_mpr))
            disp(['Size of parcellation map and flair not equal for ',fixname])
           continue 
        end
        flairmat=idx_mpr.*double(flairfile.img);
        Matrix(j,i)=sum(flairmat(:))/nnz(flairmat);

    end 
end

%% generate result excel file
result=cell(size(lsdir,1),length(Uniq_col)+1);

result(1,2:end)= cellstr('Flair');



%% write result cell to output in current folder

    result(2,2:end)= Uniq_col';
    result(1,1)= cellstr('ImageModal');
    result(2,1)= cellstr('Subject');
    for i=1: size(lsdir,1) % num of subjects 
        result(2+i,2:end)=num2cell(Matrix(:,i)'); 
        id=strtrim(lsdir(i,:));
        
        
        result(2+i,1)=cellstr(id);
    end
    % output
    xlswrite(['Summary_Level',num2str(Level),'_Type',num2str(ParcellationType),'.xlsx'],result(:,:));


toc;