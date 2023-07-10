%-----------------------------------------------------------------------
% Chenfei Ye 01/17/2017
% This script is designed for BIOCARD2 matrix Zscore analysis
% functions:
% (1) generate histogram for R and R^2
% (2) generate colormap for R^2
% (3) generate brain map of clustering
% (4) generate scatter plot for parcel pairs with R>threshold
% Output:
%
% ------cye7@jhu.edu
clc
clear
%% make sure the following variable is well set
thresholdR=0.9; % set the threshold for R
% Choose image modal (1 for volume, 4 for T2map, 5 for FA, 6 for trace, 7 for PET)
[num, txt, raw]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type1_filtered.xlsx','Sheet1'); % read excel matrix
%% read Level data to remove high amyloid subjects
[num_vol, ~, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level1_Type1_filtered.xlsx','Sheet1');
[num_PET, ~, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level1_Type1_filtered.xlsx','Sheet7');
PETall=sum(num_vol.*num_PET,2);

SUBindex_low=find(PETall>1.3e+06); % threshold of low/high amyloid sum
SUBindex_high=setdiff([1:length(PETall)],SUBindex_low); % get complimentary set
%% calculate volume percentage
Volall=sum(num_vol,2);
if strcmp(strtrim(char(raw(1,2))),'Volume')
    
    for i = 1:size(num,1)
        num(i,:)=num(i,:)./Volall(i);
    end
    
end


num2=num; num3=num;
raw2=raw; raw3=raw;
num2(SUBindex_low,:)=[]; %num2 is only low amyloid subjects
raw2(SUBindex_low+2,:)=[]; %raw2 is only low amyloid subjects
num2(22,:)=[]; %remove subject MASRAL becasue of negative PET value
raw2(22+2,:)=[]; %remove subject MASRAL becasue of negative PET value
num3(SUBindex_high,:)=[]; %num3 is only high amyloid subjects
raw3(SUBindex_high+2,:)=[]; %raw3 is only high amyloid subjects
%% remove subject MASRAL becasue of negative PET value
num(43,:)=[];
num_vol(43,:)=[];
num_PET(43,:)=[];
raw(43+2,:)=[];

%% histogram
PETall=sum(num_vol.*num_PET,2);
HighAmyIndex=find(PETall>1.3e+06); % index of subjects with high amyloid
LowAmyIndex=find(PETall<1.3e+06);  % index of subjects with low amyloid


[R,P] = corrcoef(num2); % R and pvalue of low amyloid subjects
[R3,P3] = corrcoef(num3); % R and pvalue of high amyloid subjects
% generate histogram for R and R^2
subplot(2,2,1);
hist(R(:),1000);
title(['Histogram of R for ', char(raw(1,2)),' with low amyloid']);
xlim([-1,1]);
subplot(2,2,2);
R_square=R.^2;
hist(R_square(:),1000);
xlim([0,1]);
title(['Histogram of R^2 for ', char(raw(1,2)),' with low amyloid']);
subplot(2,2,3);
hist(R3(:),1000);
xlim([-1,1]);
title(['Histogram of R for ', char(raw(1,2)),' with high amyloid']);
subplot(2,2,4);
R3_square=R3.^2;
hist(R3_square(:),1000);
xlim([0,1]);
title(['Histogram of R^2 for ', char(raw(1,2)),' with high amyloid']);


%% generate brain map of clustering
K_cluster=4;
[idx_low,~]=kmeans(R_square,K_cluster);
[idx_high,~]=kmeans(R3_square,K_cluster);
[img,pixdim,dtype] = readanalyze('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\BIOCARDII_multimodal_90subs\ABEBER\2936331_027_ABEBER_150318_MPRAGE_283Labels_M2.hdr');
img_low=img;img_high=img;
RemoveLabel_Vol=[161,162,236:239,248:251,254,276,278:280];
RemoveLabel_others=[RemoveLabel_Vol,165:175,257:274,281];
count=0;
if strcmp(strtrim(char(raw(1,2))),'Volume')
    RemoveLabel=RemoveLabel_Vol;
else
    RemoveLabel=RemoveLabel_others;
end
for i=1:max(img(:))
    if ismember(i, RemoveLabel)
        img_low(img==i)=0;
        img_high(img==i)=0;
    else
        count=count+1;
        img_low(img==i)=idx_low(count);
        img_high(img==i)=idx_high(count);
    end
end
writeanalyze(img_low,['Cluster',num2str(K_cluster),'_LowAmyloid_',strtrim(char(raw(1,2)))],pixdim,'uint8');
writeanalyze(img_high,['Cluster',num2str(K_cluster),'_HighAmyloid_',strtrim(char(raw(1,2)))],pixdim,'uint8');



%% generate colormap for R^2
figure;
imagesc(R_square);
colorbar;
title(['Colormap of R^2 for ', char(raw(1,2))]);
% %if print full strcutures along axis
% set(gca, 'xtick', 1:length(R));
% set(gca, 'ytick', 1:length(R));
% set(gca, 'xticklabel', raw(2,2:end));
% set(gca, 'yticklabel', raw(2,2:end));
xtick_vol=[0,22,34,50,60,76,90,100,116,122,128,156,162,173,239,263]; % based on lookiptable after removing CSF SKULL1 SKULL2 SKULL3 Bone marrow Chroid_LVetc Mammillary subcallosalWM_ACC Fimbria rostralWM_ACC (for volume only)
text_vol={'Frontal','Parietal','Temp','Occiptal','Limbic','Basal','midbrain','Pons&Medulla','A&PWM','CC','Inf&LimWM','Basal','Ventri','WM','Cereb'};
xtick_others=[0,22,34,50,60,76,90,100,116,122,128,156,162,228,234]; % based on lookiptable after removing structures above, plus sulcus, ventricle (for T2map/FA/Trace/PET)
text_others={'Frontal','Parietal','Temp','Occiptal','Limbic','Basal','midbrain','Pons&Medulla','A&PWM','CC','Inf&LimWM','Basal','WM','Cereb'};
if strcmp(strtrim(char(raw(1,2))),'Volume')
    for k=1:length(text_vol)
        
        h=text((xtick_vol(k+1)-xtick_vol(k))/2+xtick_vol(k),275,char(text_vol(k)));
        set(h,'Rotation',-90)
        text(-35,(xtick_vol(k+1)-xtick_vol(k))/2+xtick_vol(k),char(text_vol(k)));
        
    end
    set(gca, 'xtick', xtick_vol);
    set(gca, 'ytick', xtick_vol);
else
    for k=1:length(text_others)
        
        h2=text((xtick_others(k+1)-xtick_others(k))/2+xtick_others(k),242,char(text_others(k)));
        
        set(h2,'Rotation',-90)
        text(-35,(xtick_others(k+1)-xtick_others(k))/2+xtick_others(k),char(text_others(k)));
        
    end
    set(gca, 'xtick', xtick_others);
    set(gca, 'ytick', xtick_others);
end
set(gca,'tickdir','out');
set(gca,'xticklabel',' ')
set(gca,'yticklabel',' ')


%% calculate ratio with strong correlation
R=eye(size(num2,2))*(-1)+R; % make diagonal all 0
R_uptri=tril(R); % get upper trianular matrix of R
P_uptri=tril(P); % get upper trianular matrix of P
index=find(R_uptri>=thresholdR&P_uptri<=0.05); % find index of R>threshold
out_val=R_uptri(index); % find values of R>threshold
[row,col]=find(R_uptri>=thresholdR&P_uptri<=0.05); % row and column index of R>threshold
out=cell(length(row),2); % variable 'out' is for saving name and R value for parcel pairs
ratio=zeros(size(num,1),length(row));


for i= 1:length(row)
    out(i,1)=cellstr([char(raw(2,row(i)+1)),'\',char(raw(2,col(i)+1))]);
    out(i,2)=num2cell(out_val(i));
    ratio(:,i)=num(:,row(i))./num(:,col(i)); % ratio value of each parcel pairs
end

ratioZ=zscore(ratio); % Zscore of ratio
HighAmyRatioZ=ratioZ(HighAmyIndex,:); %  Zscore ratio of high amyloid subjects
LowAmyRatioZ=ratioZ(LowAmyIndex,:); %  Zscore ratio of high amyloid subjects

HighAmyIndexMat=repmat(1:length(out_val),length(HighAmyIndex),1); % Xaxis for scatter of high amyloid subjects
LowAmyIndexMat=repmat(1:length(out_val),length(LowAmyIndex),1); % Xaxis for scatter of low amyloid subjects




%%  generate scatter plot for parcel pairs with R>threshold
figure;
scatter(LowAmyIndexMat(:),LowAmyRatioZ(:),'bo');
hold on;
scatter(HighAmyIndexMat(:),HighAmyRatioZ(:),'r*');
legend('LowAmyRatioZscore','HighAmyRatioZscore')
Xaxis=1:length(out_val);
Xname=out(:,1);
set(gca, 'xtick', Xaxis);
set(gca, 'xticklabel', Xname);
set(gca,'XTickLabelRotation', 90);
grid on
title(['raw pair for ', char(raw(1,2)),' with threshold ',num2str(thresholdR)]);


%% remove the left-right contralateral pairs
index_name_wot=[];
for i=1:length(Xname)
    idx=cell2mat(strfind(Xname(i),'\'));
    Xnamestr=char(Xname);
    Parcel_left=strtrim(Xnamestr(i,1:idx-1));
    Parcel_right=strtrim(Xnamestr(i,idx+1:end));
    
    
    if (strcmp(Parcel_left(end),'R')||strcmp(Parcel_left(end),'L'))
        if strcmp(Parcel_left(1:end-1),Parcel_right(1:end-1))
            
            index_name_wot(end+1)=i;
        end
    elseif (strcmp(Parcel_left(end-5:end),'_pole')&&strcmp(Parcel_right(end-5:end),'_pole'))&&strcmp(Parcel_left(1:end-6),Parcel_right(1:end-6))
        index_name_wot(end+1)=i;
    end
end
Xname_wot=Xname;
Xname_wot(index_name_wot)=[];
index_name2_wot=setdiff([1:length(out_val)],index_name_wot); % get complimentary set

HighAmyRatioZ_wot=HighAmyRatioZ(:,index_name2_wot);%  Zscore ratio of high amyloid subjects
LowAmyRatioZ_wot=LowAmyRatioZ(:,index_name2_wot); %  Zscore ratio of high amyloid subjects

HighAmyIndexMat_wot=repmat(1:length(index_name2_wot),length(HighAmyIndex),1); % Xaxis for scatter of high amyloid subjects
LowAmyIndexMat_wot=repmat(1:length(index_name2_wot),length(LowAmyIndex),1); % Xaxis for scatter of low amyloid subjects

%% generate scatter plot for parcel pairs with R>threshold without left-right contralateral pairs
figure;
scatter(LowAmyIndexMat_wot(:),LowAmyRatioZ_wot(:),'b');
hold on;
scatter(HighAmyIndexMat_wot(:),HighAmyRatioZ_wot(:),'r*');
legend('LowAmyRatioZscore','HighAmyRatioZscore')
Xaxis=1:length(Xname_wot);
set(gca, 'xtick', Xaxis);
title(['remove left-right pair for ', char(raw(1,2)),' with threshold ',num2str(thresholdR)]);
set(gca, 'xticklabel', Xname_wot);
set(gca,'XTickLabelRotation', 90);
grid on
hold off


