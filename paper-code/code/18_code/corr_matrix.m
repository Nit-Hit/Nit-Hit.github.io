%-----------------------------------------------------------------------
% Chenfei Ye 01/13/2017
% This script is designed for BIOCARD2 matrix correlation analysis
% functions:
% (1) Choose the filtered excel file of BIOCARD2 matrix
% Output:
%
% ------cye7@jhu.edu
clc
clear
%% make sure the following variable is well set
ratioLR=1; % if make all ratio value>1, set ratioLR = 1
thresholdR=0.9;
[num, txt, raw]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level5_Type1_filtered.xlsx','Sheet6');
%%
[num_vol, ~, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level1_Type1_filtered.xlsx','Sheet1');
[num_PET, ~, ~]=xlsread('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Summary_Level1_Type1_filtered.xlsx','Sheet7');
PETall=sum(num_vol.*num_PET,2);
SUBindex=find(PETall>1.3e+06);
num(SUBindex,:)=[];
raw(SUBindex+2,:)=[];
%% remove subject MASRAL becasue of negative PET value
num(22,:)=[];
raw(22+2,:)=[];
%%
[R,P] = corrcoef(num);
R=eye(size(num,2))*(-1)+R;
R_uptri=tril(R);
P_uptri=tril(P);
index=find(R_uptri>=thresholdR&P_uptri<=0.05);
out_val=R_uptri(index);
[row,col]=find(R_uptri>=thresholdR&P_uptri<=0.05);
out=cell(length(row),2);
ratio=zeros(size(num,1),length(row));
Y=cell(size(num,1),length(row));
for i= 1:length(row)
    out(i,1)=cellstr([char(raw(2,row(i)+1)),'\',char(raw(2,col(i)+1))]);
    out(i,2)=num2cell(out_val(i));
    ratio(:,i)=num(:,row(i))./num(:,col(i));
    Y(:,i)=out(i,1);
end
X=reshape(ratio,numel(ratio),1);
Y=reshape(Y,numel(ratio),1);
%boxplot(X,char(Y));
%set(gca,'XTickLabelRotation', 90);
Xname=unique(Y,'stable')';
ratio_mean=mean(ratio);
index_ratioLR=find(ratio_mean<1);

%% flip the pair name and make all values >1
if ratioLR==1
    ratio(:,index_ratioLR)=1./ratio(:,index_ratioLR);
    ratio_mean=mean(ratio);
    for i=index_ratioLR
        idx=cell2mat(strfind(Xname(i),'\'));
        Xnamestr=char(Xname);
        Parcel_left=strtrim(Xnamestr(i,1:idx-1));
        Parcel_right=strtrim(Xnamestr(i,idx+1:end));
        Xname(i)=cellstr([Parcel_right,'\',Parcel_left]);
        
    end
end
ratio_std=std(ratio);

%% below is just to remove left-right pairs
if ratioLR==1
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
    
    Xname(index_name_wot)=[];
    ratio_mean(index_name_wot)=[];
    ratio_std(index_name_wot)=[];
end
%%

% figure;
% Xaxis=1:length(ratio_mean);
% bar(Xaxis,ratio_mean);
% hold on;
% errorbar(Xaxis,ratio_mean,ratio_std,'k','LineStyle','none') ;
% set(gca, 'xtick', Xaxis);
% set(gca, 'xticklabel', Xname);
% set(gca,'XTickLabelRotation', 90);
% grid on
