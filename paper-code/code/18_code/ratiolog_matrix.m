%-----------------------------------------------------------------------
% Chenfei Ye 11/27/2017
% Update:Structure-by-structure correlation only based on AP group
% This script is designed for BIOCARD2 matrix ratiolog analysis
% functions:
% (1) generate ratio_log_matrix for highamyloid and lowamyloid
% (2) generate significant correlation map by T-test after fdr
% (3) generate significant correlation map by filtering with R threshold = 0.5
% ------cye7@jhu.edu
clc
clear
close all
%% make sure the following variable is well set
img_modal=6;   % (1 for volume, 2 for Flair, 3 for T2W, 4 for T2map, 5 for FA, 6 for trace, 7 for PET, 8 for fmri)
colormapType=2; %Output of colormap: 1 for Zlogratio map, 2 for generating R map and histogram
logratioZscoreType=2; % 1 for Zscore(logratio), 2 for logratio(Zscore)
PercentThresh=95; % percentage of Rmap threshold e.g. 90 means top 10%
ParcelTestType=true; % False for nothing, True for correlation of parcel and amyloid, and parcel ttest
fitType=false; % test for R map fit robustness
LevelType=5.2; % Choose parcellation level, 4 or 4.2 or 5 or 5.2. X.2 means type 2
circularType=false; % call circularGraph.m
SaveType=true; % save file or not
amyType=2; % Amyloid axis: 1 for lobe, 2 for DVR
R2_threshold=0.9; % R threshold in correlation filtering
Parcel_DVRref=[1:22,27:44,51:56,61:70];% reference parcels for DVR threshold
switch LevelType
    case 5.2
        wholebrainList=[1:24,27:30,33:40,43:64,66:69,71:76,87:108,111:128,131:176,185:194]; % from ACR_L, ACR_R, ....
    case 5
        wholebrainList=[1:26,29:32,35:46,49:82,84:91,93:102,113:148,151:170,173:244,253:266]; % from ACR_L, ACR_R, ....
    case 4.2
        wholebrainList=[3:4,7:10,13:16,19:22,27:38,43:46,49:50,59:70]; % from ACR_L, ACR_R, ....
end
matrix_path='E:\cye_code\BIOCARD_matrix\matrix\';



%% if load fmri, change name to fmri
switch img_modal
    case 1
        img_name='Volume';
    case 2
        img_name='Flair';
    case 3
        img_name='T2W';
    case 4
        img_name='T2map';
    case 5
        img_name='FA';
    case 6
        img_name='trace';
    case 7
        img_name='PET';
    case 8
        img_name='fmri';
end


if SaveType
    mkdir('temp');
end

%% calculate amyloid measture
amyloid = amy_measure(Parcel_DVRref,amyType);
% amyloid(83)=[]; % remove WHIDAN
% amyloid(18)=[]; % remove DELMAN

%% GMM to determine the threshold of amyloid
gm = fitgmdist(amyloid,2);
% % plot pdf
% line([0.8:0.01:1.6]',gm.PComponents(2)*normpdf([0.8:0.01:1.6]',gm.mu(2),sqrt(gm.Sigma(2))),'color','b');
% hold on
% line([0.8:0.01:1.6]',gm.PComponents(1)*normpdf([0.8:0.01:1.6]',gm.mu(1),sqrt(gm.Sigma(1))),'color','r');
% hold off
% figure;
% plot([0.8:0.01:1.6]', pdf(gm,[0.8:0.01:1.6]')); % raw pdf

syms x m s p
f = symfun(p/(s*sqrt(2*pi))*exp(-((x-m)^2)/(2*(s^2))), [x, m, s, p]);
for j = 1:2
    ff(j) = f(x, gm.mu(j), sqrt(gm.Sigma(j)), gm.PComponents(j));
end
eqn = ff(1) == ff(2);
sols = solve(eqn, x);
amyloid_thr=vpa(sols, 3);
amyloid_thr=amyloid_thr(2);
display(amyloid_thr);

%% groupping subjects
HighAmyIndex=find(amyloid>=amyloid_thr); % index of subjects with high amyloid
LowAmyIndex=find(amyloid<amyloid_thr);  % index of subjects with low amyloid
if img_modal~=8
    switch LevelType
        case 5
            [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type1_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal)]); % read excel matrix
        case 5.2
            [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type2_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal)]); % read excel matrix
        case 4.2
            [num, ~, raw]=xlsread([matrix_path,'Summary_Level4_Type2_filtered_T1combine_LV_noflip.xlsx'],['Sheet',num2str(img_modal)]); % read excel matrix
    end
else
    [num, ~, raw]=xlsread([matrix_path,'Summary_Level5_Type1_filtered_T1combine_LV_flair2.xlsx'],['Sheet5']); % read excel matrix
    
end
% num(83,:)=[]; % remove WHIDAN
% raw(85,:)=[]; % remove WHIDAN
% num(18,:)=[]; % remove DELMAN
% raw(20,:)=[]; % remove DELMAN
raw_var=raw(2,2:end);
ID=raw(3:end,1);


%% Choose image modal
switch img_modal
    case 8 % fmri
        load('cor.mat'); % load fmri data, cor.mat for raw correlation, z_cor.mat for Fisher-Z data
        load('z_cor_var.mat'); % load fmri parcel name
        z_cor_var=z_cor_var';
        cor(isinf(cor))=1;
        [raw_var_L3,cor,raw_var_L5]=parcel_naming(z_cor_var,img_modal,cor);
        %[stat_R.pvalue_R_hist]=hist_R(mean(z_cor(:,:,HighAmyIndex),3),mean(z_cor(:,:,LowAmyIndex),3),img_name,SaveType); % plot histogram
    otherwise
        %% convert volume to normalized volume
        if img_modal==1
            Vol_wholebrain=sum(num(:,wholebrainList),2);
            for i =1:size(num,1)
                num(i,:)=num(i,:)./Vol_wholebrain(i);
            end
        end
        
        %% change num and raw_var from L5 to L4
        if LevelType==4
            [num,raw_var]=Level4(num,raw_var,img_modal);
        end
        
        %% confounding adjustment (not including fmri data)
        [num,Coeff]=adjustment2(num,ID,LowAmyIndex); % adjustment only use AN for adjustment, adjustment2 use both AN and AP for adjustment
        %[pvalue_hist]=hist_R(mean(num(HighAmyIndex,:),1),mean(num(LowAmyIndex,:),1),img_name,SaveType); % plot histogram
        % num=0.5*(tanh(0.01*(num-repmat(mean(num(LowAmyIndex,:),1),size(num,1),1)./repmat(std(num(LowAmyIndex,:),1),size(num,1),1)))+1);
        disp(['The number of negative num: ',num2str(nnz(find(num<0)))]);
        %% generate correlation map
        if ParcelTestType
            topnum=size(num,2); % Number of Top parcel for correlation with amyloid
            stat_parcel=par_test(num,raw_var,amyloid,topnum,HighAmyIndex,LowAmyIndex,ID); % update:only based on AP group
        end
        
        %% sort parcel name according to matrix excel file, and add level3 name
        [raw_var_L3,num,raw_var_L5]=parcel_naming(raw_var,img_modal,num,LevelType);
        %         [pvalue_hist]=hist_R(mean(num(HighAmyIndex,:),1),mean(num(LowAmyIndex,:),1),img_name,SaveType); % plot histogram
        
        %% remove brainstem parcels
        BrainStem={'RedNc_L','RedNc_R','Snigra_L','Snigra_R','CP_L','CP_R','Midbrain_L','Midbrain_R',...
            'CST_L','CST_R','SCP_L','SCP_R','MCP_L','MCP_R','PCT_L','PCT_R','Medulla_L','Medulla_R',...
            'ML_L','ML_R','Pons_L','Pons_R','ICP_L','ICP_R'};
        [C,ia,ib]=intersect(raw_var_L5,BrainStem,'stable');
        raw_var_L5(ia)=[];
        raw_var_L3(ia)=[];
        num(:,ia)=[];

        %% z-score for parcel-by-parcel analysis
        num_AN_mean=mean(num(LowAmyIndex,:),1);
        num_AP_mean=mean(num(HighAmyIndex,:),1);
        [z_num_AN_mean,mu_PBA,sigma_PBA]=zscore(num_AN_mean);
        z_num_AP_mean=(num_AP_mean-mu_PBA)/sigma_PBA;
        z_num_AN_mean=z_num_AN_mean';
        z_num_AP_mean=z_num_AP_mean';
        % z-score for PBA: individual
        z_num_AN=(num(LowAmyIndex,:)-mu_PBA)/sigma_PBA;
        z_num_AP=(num(HighAmyIndex,:)-mu_PBA)/sigma_PBA;
end

%% combine matrix
% [num, ~, raw]=xlsread(['C:\Users\susumulab\Desktop\BIOCARD_summary\','Allcombine.xlsx'],['Sheet3']); % read excel matrix
% [num, ~, ~]=xlsread(['C:\Users\susumulab\Desktop\BIOCARD_summary\','Allcombine.xlsx'],['Sheet1']); % read excel matrix
%%


switch colormapType
    case 1
        if logratioZscoreType==2
            [ZLow,mu,sigma]=zscore(num(LowAmyIndex,:));
            ZHigh=(num(HighAmyIndex,:)-repmat(mu,length(HighAmyIndex),1,1))./repmat(sigma,length(HighAmyIndex),1,1);
            ratiologHigh=zeros(length(HighAmyIndex),size(num,2),size(num,2));
            ratiologLow=zeros(length(LowAmyIndex),size(num,2),size(num,2));
            for m=1:length(HighAmyIndex)
                for i=1:size(num,2)
                    ratiologHigh(m,i,:)=log(abs(ZHigh(m,i)./ZHigh(m,:)));
                end
            end
            for m=1:length(LowAmyIndex)
                for i=1:size(num,2)
                    ratiologLow(m,i,:)=log(abs(ZLow(m,i)./ZLow(m,:)));
                end
            end
            ZratiologLow=ratiologLow;
            ZratiologHigh=ratiologHigh;
            
        elseif logratioZscoreType==1
            ratiologHigh=zeros(length(HighAmyIndex),size(num,2),size(num,2));
            ratiologLow=zeros(length(LowAmyIndex),size(num,2),size(num,2));
            for m=1:length(HighAmyIndex)
                for i=1:size(num,2)
                    ratiologHigh(m,i,:)=log(num(HighAmyIndex(m),i)./num(HighAmyIndex(m),:));
                end
            end
            for m=1:length(LowAmyIndex)
                for i=1:size(num,2)
                    ratiologLow(m,i,:)=log(num(LowAmyIndex(m),i)./num(LowAmyIndex(m),:));
                end
            end
            
            [ZratiologLow,mu,sigma]=zscore(ratiologLow);
            ZratiologHigh=(ratiologHigh-repmat(mu,length(HighAmyIndex),1,1))./repmat(sigma,length(HighAmyIndex),1,1);
        end
        
        [~,p_Zratiolog]=ttest2(ZratiologLow,ZratiologHigh);
        p_Zratiolog=squeeze(p_Zratiolog);
        Highmap=squeeze(mean(ZratiologHigh,1));
        Lowmap=squeeze(mean(ZratiologLow,1));
        Highmap(logical(eye(length(Highmap)))) = 0;
        Lowmap(logical(eye(length(Lowmap)))) = 0;
        stat_ratio.num005=length(find(triu(p_Zratiolog,1)<0.05));
        [Pmat_fdr,numfdr]=fdr_mat(p_Zratiolog);
        stat_ratio.numfdr=numfdr;
        [stat_ratio.p_005,~]=stat_mat(p_Zratiolog,raw_var_L5,Highmap,Lowmap);
        [stat_ratio.fdr,stat_ratio.fdr_reshape]=stat_mat(Pmat_fdr,raw_var_L5,Highmap,Lowmap);
        [stat_ratio.corr,stat_ratio.corr_fdr]=stat_amyloid(ZratiologLow,ZratiologHigh,raw_var_L5,amyloid,LowAmyIndex,HighAmyIndex);
        stat_ratio.num_corr=size(stat_ratio.corr,2);
        stat_ratio.num_corr_fdr=size(stat_ratio.corr_fdr,2);
        
        switch logratioZscoreType
            case 1
                colormap_name='ZlogRatio';
                stat_ZlogRatio=stat_ratio;
            case 2
                colormap_name='logRatioZ';
                stat_logRatioZ=stat_ratio;
        end
        colorbarrange=[min([Highmap(:)',Lowmap(:)']),max([Highmap(:)',Lowmap(:)'])];
        clear stat_ratio
        
        
        
    case 2
        if img_modal~=8
            [Highmap,High_corP]=corrcoef(num(HighAmyIndex,:));
            [Lowmap,Low_corP]=corrcoef(num(LowAmyIndex,:));
            % [stat_R.pvalue_R_hist]=hist_R(Highmap,Lowmap,img_name,SaveType); % plot histogram
            % statistic for Fisher Z transform
            zmap2_high=0.5*log((1+abs(Highmap))./(1-abs(Highmap)));
            zmap2_low=0.5*log((1+abs(Lowmap))./(1-abs(Lowmap)));
        else
            
            z_cor_combine=reshape(cor,size(cor,1)*size(cor,2),size(cor,3));
             [z_cor_combine,Coeff]=adjustment(z_cor_combine',ID,LowAmyIndex);
%            z_cor_combine=0.5*(tanh(0.01*(z_cor_combine-repmat(mean(z_cor_combine(LowAmyIndex,:),1),size(z_cor_combine,1),1)./repmat(std(z_cor_combine(LowAmyIndex,:),1),size(z_cor_combine,1),1)))+1);
            disp(['The number of negative num: ',num2str(nnz(find(z_cor_combine<0)))]);
            cor=reshape(z_cor_combine',size(cor,1),size(cor,2),size(cor,3)); % 如果有adjustment，则第一个输入参数为z_cor_combine'，否则为z_cor_combine
%             % ACA full triangular t-test
%             p_fMRI=zeros(size(cor,1),size(cor,2));
%             for i=1:size(cor,1)
%                 for j=1:size(cor,2)
%                     a=cor(i,j,HighAmyIndex);
%                     b=cor(i,j,LowAmyIndex);
%                     p_fMRI(i,j)=ranksum(a(:),b(:));
%                 end
%             end
%             p_fMRI_fdr=fdr_mat(p_fMRI);

%             % Regional-based functional connectivity t-test
%             r_fMRI=zeros(size(cor,3),size(cor,1));
%             for i =1:size(cor,3) % subject index
%                 for j =1:size(cor,1) % parcel index
%                     r_fMRI(i,j)=(sum(cor(j,:,i))-1)/(size(cor,3)-1);
%                 end
%             end
%             p_fMRI=zeros(1,size(cor,1));
%             for j =1:size(cor,1) % parcel index
%                 p_fMRI(:,j)=ranksum(r_fMRI(HighAmyIndex,j),r_fMRI(LowAmyIndex,j));
%             end
%             p_fMRI_fdr=spm_P_FDR(p_fMRI);
   
            
            Highmap=mean(cor(:,:,HighAmyIndex),3);
            Lowmap=mean(cor(:,:,LowAmyIndex),3);
            
            % re-assign diagnal value as mean value
            Triangle_vec_High=triu(Highmap,1);
            Triangle_vec_High=Triangle_vec_High(:);
            Triangle_vec_High(Triangle_vec_High==0)=[];
            Highmap(logical(eye(length(Highmap)))) = mean(Triangle_vec_High);
            Triangle_vec_Low=triu(Lowmap,1);
            Triangle_vec_Low=Triangle_vec_Low(:);
            Triangle_vec_Low(Triangle_vec_Low==0)=[];
            Lowmap(logical(eye(length(Lowmap)))) = mean(Triangle_vec_Low);
            % for z_cor, no need for Fisher Z transform. Already Z transformed in BrainGPS
            zmap2_high=Highmap;
            zmap2_low=Lowmap;

            % for z_cor, still need Fisher Z transform.
%             zmap2_high=0.5*log((1+abs(Highmap))./(1-abs(Highmap)));
%             zmap2_low=0.5*log((1+abs(Lowmap))./(1-abs(Lowmap)));
        end
        colormap_name='Rmap';
        colorbarrange=[min([Highmap(:)',Lowmap(:)']),max([Highmap(:)',Lowmap(:)'])];
        % compare the Fisher Z transformed correlations
        Zobserved2=(zmap2_high-zmap2_low)./sqrt((1/(length(HighAmyIndex)-3))+(1/(length(LowAmyIndex)-3)));
%         p_Zobserved2=2*(normcdf(-abs(Zobserved2))); % two-tail p value
        p_Zobserved2=(normcdf(-abs(Zobserved2))); % one-tail p value
        
        % z-score for eACA
        zmap2_high_triu=triu(zmap2_high,1);
        zmap2_high_triu_vec= zmap2_high_triu(:);
        zmap2_high_triu_vec(zmap2_high_triu_vec==0)=[];
        zmap2_low_triu=triu(zmap2_low,1);
        zmap2_low_triu_vec= zmap2_low_triu(:);
        zmap2_low_triu_vec(zmap2_low_triu_vec==0)=[];
        [zmap2_low_triu_vec,mu_eACA,sigma_eACA]=zscore(zmap2_low_triu_vec);
        zmap2_high_triu_vec=(zmap2_high_triu_vec-mu_eACA)/sigma_eACA;
        
        [Pmat_fdr,numfdr]=fdr_mat(p_Zobserved2);
        stat_R.num005=length(find(p_Zobserved2<0.05))/2;
        stat_R.numfdr=numfdr;
        [stat_R.fdr,stat_R.fdr_reshape]=stat_mat(Pmat_fdr,raw_var_L5,Highmap,Lowmap);
        
        Highmap_sq=Highmap.^2;
        Highmap_sq_triu=triu(Highmap_sq,1);
        Highmap_sq_triu_vec= Highmap_sq_triu(:);
        Highmap_sq_triu_vec(Highmap_sq_triu_vec==0)=[];
        Highmap_sq_triu_vec_sort=sort(Highmap_sq_triu_vec,'descend');
        ThreshValue_High=prctile(Highmap_sq_triu_vec_sort,PercentThresh);
        Threshmap_High=Highmap_sq>ThreshValue_High;
        Threshmap_High(tril(true(length(Threshmap_High))))=0;
        disp(['The number of fdr area for HAN = ',num2str(nnz(Threshmap_High))])
        disp(['The R threshold for HAN = ',num2str(ThreshValue_High)])
        
        Lowmap_sq=Lowmap.^2;
        Lowmap_sq_triu=triu(Lowmap_sq,1);
        Lowmap_sq_triu_vec= Lowmap_sq_triu(:);
        Lowmap_sq_triu_vec(Lowmap_sq_triu_vec==0)=[];
        Lowmap_sq_triu_vec_sort=sort(Lowmap_sq_triu_vec,'descend');
        ThreshValue_Low=prctile(Lowmap_sq_triu_vec_sort,PercentThresh);
        Threshmap_Low=Lowmap_sq>ThreshValue_Low;
        Threshmap_Low(tril(true(length(Threshmap_Low))))=0;
        disp(['The number of fdr area for LAN = ',num2str(nnz(Threshmap_Low))])
        disp(['The R threshold for LAN = ',num2str(ThreshValue_Low)])
        [stat_R.num_Low,stat_R.num_High,stat_R.fdr_Low,stat_R.fdr_High,p_mat_Low_triu_fdr,p_mat_High_triu_fdr]=stat_mat_oneway(p_Zobserved2,raw_var_L5,Highmap,Lowmap,Threshmap_High,Threshmap_Low);
        
        
        if img_modal~=8
            CorPmap_High=fdr_mat(High_corP); % within-group correlation map Pvalue
            CorPmap_Low=fdr_mat(Low_corP); % within-group correlation map Pvalue
            CorPmap_High_2=(CorPmap_High<0.05)&(Highmap>Lowmap);
            CorPmap_Low_2=(CorPmap_Low<0.05)&(Highmap<Lowmap);
            %             Threshmap_High=Highmap.^2>0.5;
            %             Threshmap_Low=Lowmap.^2>0.5;
            CorPmap_union=CorPmap_High_2|CorPmap_Low_2;
            Pmat_fdr_onesideStrongR=Pmat_fdr; % initilize Pmat_fdr_onesideStrongR
            Pmat_fdr_onesideStrongR(CorPmap_union==0)=1;
            [stat_R.fdr_onesideStrongR,stat_R.fdr_onesideStrongR_reshape]=stat_mat(Pmat_fdr_onesideStrongR,raw_var_L5,Highmap,Lowmap);
            stat_R.numfdr_onesideStrongR=length(find(Pmat_fdr_onesideStrongR<0.05))/2;
            
            
            CorPmap_High(CorPmap_High<0.05)=1;
            CorPmap_High(CorPmap_High~=1)=0;
            CorPmap_Low(CorPmap_Low<0.05)=1;
            CorPmap_Low(CorPmap_Low~=1)=0;
            
            CorPmap_intersect=CorPmap_High.*CorPmap_Low;
            Pmat_fdr_bothStrongR=Pmat_fdr; % initilize Pmat_fdr_bothStrongR
            Pmat_fdr_bothStrongR(CorPmap_intersect==0)=1;
            [stat_R.fdr,stat_R.fdr_reshape]=stat_mat(Pmat_fdr,raw_var_L5,Highmap,Lowmap);
            [stat_R.fdr_bothStrongR,stat_R.fdr_bothStrongR_reshape]=stat_mat(Pmat_fdr_bothStrongR,raw_var_L5,Highmap,Lowmap);
            stat_R.numfdr_bothStrongR=length(find(Pmat_fdr_bothStrongR<0.05))/2;
            
            diffmap=zeros(size(p_mat_Low_triu_fdr));
            diffmap(p_mat_Low_triu_fdr<0.05&Highmap>Lowmap)=1;
            diffmap(p_mat_Low_triu_fdr<0.05&Highmap<Lowmap)=2;
            
            if circularType
                [~,idc,idx]=unique(raw_var_L3,'stable');
                numNodes=length(diffmap);
                numColor=length(idc);
                %raw_color=[colorcube(numColor/2);colorcube(numColor/2)];
                raw_color=[1,0,0; 0.6,1,0.6; 0,0,0;1,0.6,0;0,1,1;1,0,1;0.3,0,0; 0,0.3,0; ...
                    0,0,0.3;0.3,0.3,0;0,0.3,0.3;0.3,0,0.3;...
                    0.6,0,0; 0,0.6,0; 0,0,0.6;0.6,0.6,0;0,0.6,0.6;0.6,0,0.6;];
                raw_color=repmat(raw_color,2,1);
                new_color=zeros(numNodes,3);
                for i = 1:numNodes
                    new_color(i,:)=raw_color(idx(i),:);
                end
                % rerank to symetric circle
                temp1=diffmap(end:-1:(end/2+1),:);
                diffmap1=[diffmap(1:end/2,:);temp1];
                temp2=diffmap1(:,end:-1:end/2+1);
                diffmap2=[diffmap1(:,1:end/2),temp2];
                raw_var_L3_sysmetric=[raw_var_L3(1:end/2),raw_var_L3(end:-1:end/2+1)];
                new_color=[new_color(1:end/2,:);new_color(end:-1:end/2+1,:)];
                figure;
                %                 circularGraph(diffmap2,'Colormap',new_color,'Label',raw_var_L3_sysmetric');
                circularGraph(diffmap2,'Colormap',new_color,'Label',repmat({' '},numNodes,1));
                savefig(gcf,['temp\CircularGraph']);
                return
            end
            
            
            if fitType
                fitmat=residual_test(num,HighAmyIndex,LowAmyIndex);
                fitmat_fdr = spm_P_FDR(fitmat);% FDR correction
                fitmap=zeros(size(num,2),size(num,2));
                fitmap_fdr=fitmap;
                fitmap(fitmat<0.05)=1;
                fitmap((fitmap.*fitmap')==1)=2;
                fitmap_fdr(fitmat_fdr<0.05)=1;
                fitmap_fdr((fitmap_fdr.*fitmap_fdr')==1)=2;
                
            end
        else
            [stat_R.fdr,stat_R.fdr_reshape]=stat_mat(Pmat_fdr,raw_var_L5,Highmap,Lowmap);
            diffmap=zeros(size(Highmap));
            diffmap(Pmat_fdr<0.05&Highmap>Lowmap)=1;
            diffmap(Pmat_fdr<0.05&Highmap<Lowmap)=2;
            if circularType
                [~,idc,idx]=unique(raw_var_L3,'stable');
                numNodes=length(diffmap);
                numColor=length(idc);
                %raw_color=colorcube(numColor);
                raw_color=[1,0,1;0.3,0,0; 0,0.3,0; ...
                    0,0,0.3;0.3,0.3,0;0,0.3,0.3;0.3,0,0.3;...
                    0.6,0,0; 0.6,0,0.6;];
                raw_color=repmat(raw_color,2,1);
                new_color=zeros(numNodes,3);
                for i = 1:numNodes
                    new_color(i,:)=raw_color(idx(i),:);
                end
                % rerank to symetric circle
                temp1=diffmap(end:-1:(end/2+1),:);
                diffmap1=[diffmap(1:end/2,:);temp1];
                temp2=diffmap1(:,end:-1:end/2+1);
                diffmap2=[diffmap1(:,1:end/2),temp2];
                raw_var_L3_sysmetric=[raw_var_L3(1:end/2),raw_var_L3(end:-1:end/2+1)];
                new_color=[new_color(1:end/2,:);new_color(end:-1:end/2+1,:)];
                figure;
                %                 circularGraph(diffmap2,'Colormap',new_color,'Label',raw_var_L3');
                circularGraph(diffmap2,'Colormap',new_color,'Label',repmat({' '},numNodes,1));
                savefig(gcf,['temp\CircularGraph']);
                return
            end
        end
        
end

%% plot colormap for both groups
if stat_R.num_High<4
    display('Not enough significant connections')
else
    h_scatter=scatter4(num,ID,LowAmyIndex,HighAmyIndex,stat_R,raw_var_L5);
end

[text_label,ia,ic] = unique(raw_var_L3,'stable');
xtick=[ia'-1,length(raw_var_L3)];
if ~(colormapType==1&&logratioZscoreType==1)
    h_map(1)=colormap_plot(Highmap,img_name,[colormap_name,'of HAN'],text_label,xtick,LevelType,colorbarrange);
    h_map(2)=colormap_plot(Lowmap,img_name,[colormap_name,'of LAN'],text_label,xtick,LevelType,colorbarrange);
    if colormapType==2
        h_map(3)=colormap_plot(diffmap,img_name,[colormap_name,'of substraction)'],text_label,xtick,LevelType,[0,2]);
        if length(unique(diffmap))==3
            colormap([143/255 255/255 111/255;0 0 1;1 0 0]);
        elseif length(unique(diffmap))==2&&ismember(1,unique(diffmap))
            colormap([143/255 255/255 111/255;0 0 1]);
        elseif length(unique(diffmap))==2&&ismember(2,unique(diffmap))
            colormap([143/255 255/255 111/255;1 0 0]);
        elseif length(unique(diffmap))==1
            colormap([143/255 255/255 111/255]);
        end
    end
end

if colormapType==2&&img_modal~=8
    h_Pmap(1)=colormap_plot(CorPmap_High,img_name,' Pmap of correlation of HAN',text_label,xtick,LevelType);
    colormap([143/255 255/255 111/255;1 0 0]);
    h_Pmap(2)=colormap_plot(CorPmap_Low,img_name,' Pmap of correlation of LAN',text_label,xtick,LevelType);
    colormap([143/255 255/255 111/255;1 0 0]);
end

if colormapType==2&&fitType
    h_fitmap(1)=colormap_plot(fitmap,img_name,' Goodness of fit',text_label,xtick,LevelType,[0,2]);
    if length(unique(fitmap))==3
        colormap([143/255 255/255 111/255;0 0 1;1 0 0]);
    elseif length(unique(fitmap))==2
        colormap([143/255 255/255 111/255;0 0 1]);
    elseif length(unique(fitmap))==1
        colormap([143/255 255/255 111/255]);
    end
    h_fitmap(2)=colormap_plot(fitmap_fdr,img_name,' Goodness of fit after FDR',text_label,xtick,LevelType,[0,2]);
    if length(unique(fitmap_fdr))==3
        colormap([143/255 255/255 111/255;0 0 1;1 0 0]);
    elseif length(unique(fitmap_fdr))==2
        colormap([143/255 255/255 111/255;0 0 1]);
    elseif length(unique(fitmap_fdr))==1
        colormap([143/255 255/255 111/255]);
    end
end

if SaveType
    if exist('h_map')
        if colormapType==1&&logratioZscoreType==1
            savefig(h_map,['temp\ZlogRatiomap']);
        elseif colormapType==1&&logratioZscoreType==2
            savefig(h_map,['temp\logRatioZmap']);
        elseif colormapType==2
            savefig(h_map,['temp\Rmap']);
        end
    end
    if exist('h_Pmap')
        savefig(h_Pmap,['temp\Pmap']);
    end
    if exist('h_scatter')
        savefig(h_scatter,['temp\scatter4']);
    end
    if exist('fitmap')
        savefig(h_fitmap,['temp\fitmap']);
    end
    save('temp\parcelname','raw_var_L5');
    if exist('fitmat')
        save('temp\fitmat.mat','fitmat');
    end
    if exist('stat_parcel')
        save('temp\stat_parcel.mat','stat_parcel');
    end
    if exist('stat_ZlogRatio')
        save('temp\stat_ZlogRatio.mat','stat_ZlogRatio');
    end
    if exist('stat_logRatioZ')
        save('temp\stat_logRatioZ.mat','stat_logRatioZ');
    end
    if exist('stat_R')
        save('temp\stat_R.mat','stat_R');
    end
end

%% dots plot and save logratio.jpg of the dots
% onlyHigh:red circle, onlyLow:black circle, both:pink circle
if colormapType==5
    switch fmriType
        case 0
            dots_plot_fix(Highmap,Lowmap,R2_threshold,raw_var_L5,amyloid,num);
        case 1
            dots_plot_fix(Highmap,Lowmap,R2_threshold,raw_var_L5,amyloid);
    end
end


