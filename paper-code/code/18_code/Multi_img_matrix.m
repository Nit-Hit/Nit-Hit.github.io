%-----------------------------------------------------------------------
% Chenfei Ye updated:01/10/2017
% Update: add left-right flip for parcellation map
% This script is designed for creating matrix for BIOCARDII images (mpr/FLAIR/T2w/T2map/FA/Trace/PET)
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
minTrace=0.0015; % set the minimum threshold for Trace (fining parcellation)
maxTrace=0.0045; % set the maximum threshold for Trace (fining parcellation)
minT2map=0; % set the minimum threshold for T2map (fining parcellation)
maxT2map=200; % set the maximum threshold for T2map (fining parcellation)
Level=5;% level of parcellation granularity
ParcellationType=1; % choose Type1 or Type2
numofMultimodal=7; % Number of multimodal MRI (default including MPRAGE/Flair/T2W/T2map/FA/Trace/PET)
sliceNum=150;
FlipName={'COFPAT','DEMBAR','DUNEVE','GINGLE','POWJES','RIGJUD','SMIMEG','THODAV','WOLBAR'};

% set the input folder path
mainpath='E:\cye_code\BIOCARD_matrix\BIOCARDII_multimodal_95subs';
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
Matrix=zeros(size((Uniq_col),1),numofMultimodal,size(lsdir_PET,1)); % create Matrix
ID=cellstr(lsdir_PET);

for i =1:length(ID) % for each subject
    PETname=strtrim(lsdir_PET(i,:));
    id=strfind(PETname,'_');
    id_first=id(1);
    fixname=PETname(1:(id_first-1)); % select fixname of each subject name
    sMRIfolder=ls([sMRIpath,'\*',fixname,'*']); % select main folder of each subject 
    DTIfolder=ls([DTIpath,'\*',fixname,'*']); % select DTI folder of each subject 
    Parmapfolder=ls([Parmappath,'\*',fixname,'*']); % select parcellation map folder of each subject 
    if isempty(sMRIfolder)||isempty(DTIfolder)||isempty(Parmapfolder)
        disp(['some modal Lack for ',fixname]);
        continue
    end
    sub2_path=dir([sMRIpath,'\',sMRIfolder]); %return subdirectory info of main folder
    
    %% make sure the name and organization below is correct
%     mprimage=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*MPRAGE']);
% %     flairimage=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*FLAIR']);
%     T2Wimage=ls([sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\*T2AX']);
%     
%     mprpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',mprimage,'\moWIPMPRAGESENSE.nii'];
% %     flairpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',flairimage,'\rmWIPFLAIRSENSE.nii'];
% %     T2Wpath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',T2Wimage,'\rmWIPSkinnyT2AXSENSEA.nii'];
%     T2mappath=[sMRIpath,'\',sMRIfolder,'\',sub2_path(3).name,'\scans\',T2Wimage,'\rT2_map.nii'];
%     FAmappath=[DTIpath,'\',DTIfolder,'\QcDtiMap\rFaMap.img'];
%     Tracepath=[DTIpath,'\',DTIfolder,'\QcDtiMap\rTrace.img'];
%     PETmappath=[PETpath,'\',fixname,'_PET_registerd.nii'];
%     Parname=ls([Parmappath,'\',Parmapfolder,'\*_283Labels_M2.nii']);
%     Parpath=[Parmappath,'\',Parmapfolder,'\',Parname];
%     mprpath=[mainpath,'\',fixname,'\moWIPMPRAGESENSE.nii'];
%     T2mappath=[mainpath,'\',fixname,'\rT2_map.nii'];
%     FAmappath=[mainpath,'\',fixname,'\rFaMap.img'];
%     Tracepath=[mainpath,'\',fixname,'\rTrace.img'];
    PETmappath=[mainpath,'\',fixname,'\',fixname,'_PET_registerd.nii'];
    Parname=ls([mainpath,'\',fixname,'\*_283Labels_M2.img']);
    Parpath=[mainpath,'\',fixname,'\',Parname];
    
    
    %% load each image modal and correct the NaN value
    %% PlanRaw for orientation test: load_untouch_nii 
%     flairfile = load_untouch_nii(flairpath);
%     flairfile.img(isnan(flairfile.img)==1) = 0;
%     T2Wfile = load_untouch_nii(T2Wpath);
%     T2Wfile.img(isnan(T2Wfile.img)==1) = 0;
%     T2mapfile = load_untouch_nii(T2mappath);
%     FAmapfile = load_untouch_nii(FAmappath);
%     FAmapfile.img(isnan(FAmapfile.img)==1) = 0;
%     Tracefile = load_untouch_nii(Tracepath);
%     Tracefile.img(isnan(Tracefile.img)==1) = 0;
    PETfile = load_untouch_nii(PETmappath);
    PETfile.img(isnan(PETfile.img)==1) = 0;
    Parfile = load_untouch_nii(Parpath);
    pixvol=Parfile.hdr.dime.pixdim(2)*Parfile.hdr.dime.pixdim(3)*Parfile.hdr.dime.pixdim(4);
    if ~ismember(fixname,FlipName)
        Parfile.img=flipud(Parfile.img);%Make sure all images are correctly aligned before running (avoid left-right flip)
    end
    
%     subplot(2,2,1);
%     imshow(mprfile.img(:,:,sliceNum),[])
%     subplot(2,2,2);
%     imshow(T2mapfile.img(:,:,sliceNum),[])
%     subplot(2,2,3);
%     imshow(Tracefile.img(:,:,sliceNum),[])
%     subplot(2,2,4);
%     imshow(Parfile.img(:,:,sliceNum),[])
    
    
    %% PlanA for orientation test: load_nii 
%     mprfile = load_nii(mprpath,[],[],[],[],[],1);
%     pixvol=mprfile.hdr.dime.pixdim(2)*mprfile.hdr.dime.pixdim(3)*mprfile.hdr.dime.pixdim(4);
%     T2mapfile = load_nii(T2mappath,[],[],[],[],[],1);
%     FAmapfile = load_nii(FAmappath,[],[],[],[],[],1);
%     FAmapfile.img(isnan(FAmapfile.img)==1) = 0;
%     Tracefile = load_nii(Tracepath,[],[],[],[],[],1);
%     Tracefile.img(isnan(Tracefile.img)==1) = 0;
%     PETfile = load_nii(PETmappath,[],[],[],[],[],1);
%     PETfile.img(isnan(PETfile.img)==1) = 0;
%     Parfile = load_nii(Parpath,[],[],[],[],[],1);
%     Parfile.img=flipud(Parfile.img);%Make sure all images are correctly aligned before running (avoid left-right flip)
%     
%     subplot(2,2,1);
%     imshow(mprfile.img(:,:,sliceNum),[])
%     subplot(2,2,2);
%     imshow(T2mapfile.img(:,:,sliceNum),[])
%     subplot(2,2,3);
%     imshow(Tracefile.img(:,:,sliceNum),[])
%     subplot(2,2,4);
%     imshow(Parfile.img(:,:,sliceNum),[])
    

    %% PlanB for orientation test: spm_read_vols
%     mpr_info = spm_vol(mprpath);
%     mprfile.img = spm_read_vols(mpr_info);
%     T2map_info = spm_vol(T2mappath);
%     T2mapfile.img = spm_read_vols(T2map_info);
%     Trace_info = spm_vol(Tracepath);
%     Tracefile.img = spm_read_vols(Trace_info);
%     Par_info = spm_vol(Parpath);
%     Parfile.img = spm_read_vols(Par_info);
%     Parfile.img=flipud(Parfile.img); %Make sure all images are correctly aligned before running (avoid left-right flip)
%     subplot(2,2,1);
%     imshow(mprfile.img(:,:,sliceNum),[])
%     subplot(2,2,2);
%     imshow(T2mapfile.img(:,:,sliceNum),[])
%     subplot(2,2,3);
%     imshow(Tracefile.img(:,:,sliceNum),[])
%     subplot(2,2,4);
%     imshow(Parfile.img(:,:,sliceNum),[])
    
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
        
% %         if ~all(size(double(flairfile.img))==size(idx_mpr))
% %             disp(['Size of parcellation map and flair not equal for ',fixname])
% %            continue 
% %         end
% %         flairmat=idx_mpr.*double(flairfile.img);
% %         Matrix(j,2,i)=sum(flairmat(:))/nnz(flairmat);

       PETmat=idx_mpr.*double(PETfile.img);
       Matrix(j,7,i)=sum(PETmat(:))/nnz(PETmat);
        % fining parcellation with threshold
%         idx_T2mapThreshold=double(T2mapfile.img<maxT2map&T2mapfile.img>minT2map);
%        idx_traceThreshold=double(Tracefile.img<maxTrace&Tracefile.img>minTrace);
        % do not implement parcellation fining for CSF
%         if strcmp(char(Uniq_col(j)),'CSF')
%             idx_T2mapThreshold=ones(size(idx_mpr));
%             idx_traceThreshold=ones(size(idx_mpr));
%         end
        % fining parcellation with threshold for T2W/T2map/FA/Trace
%         T2Wmat=idx_T2mapThreshold.*idx_mpr.*double(T2Wfile.img);
%         T2mapmat=idx_T2mapThreshold.*idx_mpr.*double(T2mapfile.img);
%        FAmapmat=idx_traceThreshold.*idx_mpr.*double(FAmapfile.img);
%        tracemat=idx_traceThreshold.*idx_mpr.*double(Tracefile.img);
        % calculate average intensity for T2W/T2map/FA/Trace
%        Matrix(j,3,i)=sum(T2Wmat(:))/nnz(T2Wmat);
%         Matrix(j,4,i)=sum(T2mapmat(:))/nnz(T2mapmat);
%        Matrix(j,5,i)=sum(FAmapmat(:))/nnz(FAmapmat);
%        Matrix(j,6,i)=sum(tracemat(:))/nnz(tracemat);

    end 
    close all
end

%% generate result excel file
result=cell(size(lsdir_PET,1),length(Uniq_col)+1,numofMultimodal);
result(1,2:end,1)=cellstr('Volume');
result(1,2:end,2)= cellstr('Flair');
result(1,2:end,3)= cellstr('T2W');
result(1,2:end,4)= cellstr('T2map');
result(1,2:end,5)= cellstr('FA');
result(1,2:end,6)= cellstr('Trace');
result(1,2:end,7)= cellstr('PET');


%% write result cell to output in current folder
for j=1:numofMultimodal % num of modals
    result(2,2:end,j)= Uniq_col';
    result(1,1,j)= cellstr('ImageModal');
    result(2,1,j)= cellstr('Subject');
    for i=1: size(lsdir_PET,1) % num of subjects 
        result(2+i,2:end,j)=num2cell(Matrix(:,j,i)'); 
        PETname=strtrim(lsdir_PET(i,:));
        id=strfind(PETname,'_');
        fixname=PETname(1:(id(1)-1));
        result(2+i,1,j)=cellstr(fixname);
    end
    % output
    xlswrite(['Summary_Level',num2str(Level),'_Type',num2str(ParcellationType),'.xlsx'],result(:,:,j),j);
end

toc;