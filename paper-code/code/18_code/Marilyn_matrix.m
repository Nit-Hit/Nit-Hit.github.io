%-----------------------------------------------------------------------
% Chenfei Ye 02/28/2017
% This script is designed for Dr.Albert's task
% ------cye7@jhu.edu
clc
clear
%% make sure the following variable is well set
amyType=3; % Amyloid axis: 1 for ICV, 2 for lobe, 3 for DCR
Parcel_DVRref=[1:22,27:44,51:56,61:70];% reference parcels for DVR threshold
matrix_path='C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\';

[num1, ~, raw1]=xlsread([matrix_path,'Summary_Level5_Type1_filtered.xlsx'],['Sheet1']); % read volume matrix
[num4, ~, raw4]=xlsread([matrix_path,'Summary_Level5_Type1_filtered.xlsx'],['Sheet4']); % read T2map matrix
[num5, ~, raw5]=xlsread([matrix_path,'Summary_Level5_Type1_filtered.xlsx'],['Sheet5']); % read FA matrix
[num6, ~, raw6]=xlsread([matrix_path,'Summary_Level5_Type1_filtered.xlsx'],['Sheet6']); % read Trace matrix
[num7, ~, raw7]=xlsread([matrix_path,'Summary_Level5_Type1_filtered.xlsx'],['Sheet7']); % read Trace matrix
raw_var1=raw1(2,2:end);
raw_var4=raw4(2,2:end);
ID=raw1(3:end,1);
ID(43,:)=[];% remove subject MASRAL becasue of negative PET value
num1(43,:)=[];% remove subject MASRAL becasue of negative PET value
num4(43,:)=[];% remove subject MASRAL becasue of negative PET value
num5(43,:)=[];% remove subject MASRAL becasue of negative PET value
num6(43,:)=[];% remove subject MASRAL becasue of negative PET value
num7(43,:)=[];% remove subject MASRAL becasue of negative PET value

%% calculate amyloid measture for X axis
amyloid = amy_measure(Parcel_DVRref,amyType);
amyloid(43,:)=[];% remove subject MASRAL becasue of negative PET value
HighAmyIndex=find(amyloid>=1.06); % index of subjects with high amyloid
LowAmyIndex=find(amyloid<1.06);  % index of subjects with low amyloid

%% convert volume to normalized volume (ICV = sum of vols on Level 1)
[num_vol_L1, ~, ~]=xlsread([matrix_path,'\Summary_Level1_Type1_filtered.xlsx'],'Sheet1');
Vol_icv=sum(num_vol_L1,2);
for i =1:size(num1,1)
    num1(i,:)=num1(i,:)./Vol_icv(i);
end


%% intersection of T1 varname and other varname
[raw_var,ia,ib]=intersect(raw_var1,raw_var4,'stable'); %  C = A(ia) and C = B(ib).
num1=num1(:,ia);


%% sort parcel name according to matrix excel file, and add level3 name
[raw_var_L3,num1,raw_var_L5]=parcel_naming(raw_var,'Volume',0,num1);
[~,num4,~]=parcel_naming(raw_var,'T2map',0,num4);
[~,num5,~]=parcel_naming(raw_var,'FA',0,num5);
[~,num6,~]=parcel_naming(raw_var,'trace',0,num6);
[~,num7,~]=parcel_naming(raw_var,'PET',0,num7);
[text_label,ia,ic] = unique(raw_var_L3,'stable');
xtick=[ia'-1,length(raw_var_L3)];


%% make correlation matrix for LowAmyIndex
cormap=zeros(10,238);pmap=zeros(10,238);
[rvalue,pvalue]=corr(num1(LowAmyIndex,:),num4(LowAmyIndex,:));% T1-T2
cormap(1,:)=diag(rvalue)';pmap(1,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num1(LowAmyIndex,:),num5(LowAmyIndex,:));% T1-FA
cormap(2,:)=diag(rvalue)';pmap(2,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num1(LowAmyIndex,:),num6(LowAmyIndex,:));% T1-MD
cormap(3,:)=diag(rvalue)';pmap(3,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num1(LowAmyIndex,:),num7(LowAmyIndex,:));% T1-PET
cormap(4,:)=diag(rvalue)';pmap(4,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num4(LowAmyIndex,:),num5(LowAmyIndex,:));% T2-FA
cormap(5,:)=diag(rvalue)';pmap(5,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num4(LowAmyIndex,:),num6(LowAmyIndex,:));% T2-MD
cormap(6,:)=diag(rvalue)';pmap(6,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num4(LowAmyIndex,:),num7(LowAmyIndex,:));% T2-PET
cormap(7,:)=diag(rvalue)';pmap(7,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num5(LowAmyIndex,:),num6(LowAmyIndex,:));% FA-MD
cormap(8,:)=diag(rvalue)';pmap(8,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num5(LowAmyIndex,:),num7(LowAmyIndex,:));% FA-PET
cormap(9,:)=diag(rvalue)';pmap(9,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num6(LowAmyIndex,:),num7(LowAmyIndex,:));% MD-PET
cormap(10,:)=diag(rvalue)';pmap(10,:)=diag(pvalue)';
imagesc(cormap);
colormap('jet');
colorbar;
set(gca,'yticklabel',{'T1-T2','T1-FA','T1-MD','T1-PET','T2-FA','T2-MD','T2-PET','FA-MD','FA-PET','MD-PET'});
set(gca,'xticklabel',' ');
set(gca,'tickdir','out');
set(gca, 'xtick', xtick);
hold on
for k=1:length(text_label)
    text((xtick(k+1)-xtick(k))/2+xtick(k),10.6,char(text_label(k)),'rotation',-90);
end
title('Correlation coefficient for LowAmyIndex')
hold off
cormap_low=cormap;
pmap_low=pmap;

%% make correlation matrix for HighAmyIndex
figure;
cormap=zeros(10,238);pmap=zeros(10,238);
[rvalue,pvalue]=corr(num1(HighAmyIndex,:),num4(HighAmyIndex,:));% T1-T2
cormap(1,:)=diag(rvalue)';pmap(1,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num1(HighAmyIndex,:),num5(HighAmyIndex,:));% T1-FA
cormap(2,:)=diag(rvalue)';pmap(2,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num1(HighAmyIndex,:),num6(HighAmyIndex,:));% T1-MD
cormap(3,:)=diag(rvalue)';pmap(3,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num1(HighAmyIndex,:),num7(HighAmyIndex,:));% T1-PET
cormap(4,:)=diag(rvalue)';pmap(4,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num4(HighAmyIndex,:),num5(HighAmyIndex,:));% T2-FA
cormap(5,:)=diag(rvalue)';pmap(5,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num4(HighAmyIndex,:),num6(HighAmyIndex,:));% T2-MD
cormap(6,:)=diag(rvalue)';pmap(6,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num4(HighAmyIndex,:),num7(HighAmyIndex,:));% T2-PET
cormap(7,:)=diag(rvalue)';pmap(7,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num5(HighAmyIndex,:),num6(HighAmyIndex,:));% FA-MD
cormap(8,:)=diag(rvalue)';pmap(8,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num5(HighAmyIndex,:),num7(HighAmyIndex,:));% FA-PET
cormap(9,:)=diag(rvalue)';pmap(9,:)=diag(pvalue)';
[rvalue,pvalue]=corr(num6(HighAmyIndex,:),num7(HighAmyIndex,:));% MD-PET
cormap(10,:)=diag(rvalue)';pmap(10,:)=diag(pvalue)';
imagesc(cormap);
colormap('jet');
colorbar;
set(gca,'yticklabel',{'T1-T2','T1-FA','T1-MD','T1-PET','T2-FA','T2-MD','T2-PET','FA-MD','FA-PET','MD-PET'});
set(gca,'xticklabel',' ');
set(gca,'tickdir','out');
set(gca, 'xtick', xtick);
hold on
for k=1:length(text_label)
    text((xtick(k+1)-xtick(k))/2+xtick(k),10.6,char(text_label(k)),'rotation',-90);
end
title('Correlation coefficient for HighAmyIndex')
hold off
cormap_high=cormap;
pmap_high=pmap;


%% make table
sta_cell=cell(10,1);
sta_cell(1,1)={'T1-T2'};
sta_cell(2,1)={'T1-FA'};
sta_cell(3,1)={'T1-MD'};
sta_cell(4,1)={'T1-PET'};
sta_cell(5,1)={'T2-FA'};
sta_cell(6,1)={'T2-MD'};
sta_cell(7,1)={'T2-PET'};
sta_cell(8,1)={'FA-MD'};
sta_cell(9,1)={'FA-PET'};
sta_cell(10,1)={'MD-PET'};

% LowAmy
for m=1:10
    idx=find(cormap_low(m,:)>0.5);
    if ~isempty(idx)
        for i =1:length(idx)
            sta_cell(m,i+1)={[char(raw_var_L5(idx(i))),' R=',num2str(cormap_low(m,idx(i))),' P=',num2str(pmap_low(m,idx(i)))]};
        end
    end
end
sta_cell_low=sta_cell;
% HighAmy
for m=1:10
    idx=find(cormap_high(m,:)>0.5);
    if ~isempty(idx)
        for i =1:length(idx)
            sta_cell(m,i+1)={[char(raw_var_L5(idx(i))),' R=',num2str(cormap_high(m,idx(i))),' P=',num2str(pmap_high(m,idx(i)))]};
        end
    end
end
sta_cell_high=sta_cell;

%% correlation statitics
cormap_high=abs(cormap_high);
cormap_low=abs(cormap_low);
zmap_high=0.5*log((1+cormap_high)./(1-cormap_high));
zmap_low=0.5*log((1+cormap_low)./(1-cormap_low));
Zobserved=(zmap_high-zmap_low)./sqrt((1/(length(HighAmyIndex)-3))+(1/(length(LowAmyIndex)-3)));
p_Zobserved=2*(normcdf(-abs(Zobserved))); % two-tail p value

for m=1:10
    idx=find(p_Zobserved(m,:)<0.05);
    if ~isempty(idx)
        for i =1:length(idx)
            p_cell(m,i+1)={[char(raw_var_L5(idx(i))),' P=',num2str(p_Zobserved(m,idx(i)))]};
        end
    end
end
p_cell(:,1)=sta_cell(:,1);


%% T2map R statistics
Highmap=abs(corrcoef(num4(HighAmyIndex,:)));
Lowmap=abs(corrcoef(num4(LowAmyIndex,:)));
zmap2_high=0.5*log((1+Highmap)./(1-Highmap));
zmap2_low=0.5*log((1+Lowmap)./(1-Lowmap));
Zobserved2=(zmap2_high-zmap2_low)./sqrt((1/(length(HighAmyIndex)-3))+(1/(length(LowAmyIndex)-3)));
p_Zobserved2=2*(normcdf(-abs(Zobserved2))); % two-tail p value
figure;
imagesc(p_Zobserved2);
colormap('jet');
colorbar;
set(gca,'xticklabel',' ');
set(gca,'yticklabel',' ');
set(gca,'tickdir','out');
set(gca, 'xtick', xtick);
set(gca, 'ytick', xtick);
hold on
for k=1:length(text_label)
    text((xtick(k+1)-xtick(k))/2+xtick(k),242,char(text_label(k)),'rotation',-90);
    text(-35,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
end
title('Pmap for T2map between two groups')


idx_sig=find(p_Zobserved2<0.001); % index of significant dots
plot(ceil(idx_sig/length(p_Zobserved2)),mod(idx_sig,length(p_Zobserved2)),'yo','MarkerSize',12,'linewidth',4);


hold off

p2_cell=cell(length(p_Zobserved2),1);
for m=1:length(p_Zobserved2)
    idx=find(p_Zobserved2(m,:)<0.001);
    if ~isempty(idx)
        for i =1:length(idx)
            p2_cell(m,i+1)={[char(raw_var_L5(m)),' & ',char(raw_var_L5(idx(i))),' P=',num2str(p_Zobserved2(m,idx(i)))]};
        end
    end
end
p2_cell(:,1)=raw_var_L5';
