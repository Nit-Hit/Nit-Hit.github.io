%-----------------------------------------------------------------------
% Chenfei Ye 06/20/2017
% This script is designed for one-way FDR correction on BIOCARD data. FDR
% range only apply on Highmap or Lowmap with significant correlations or
% certain R threshold
% Output: p_cell  saves significant connectivity
% ------cye7@jhu.edu

function [num_Low,num_High,p_cell_Low,p_cell_High,p_mat_Low_triu_fdr,p_mat_High_triu_fdr]=stat_mat_oneway(Pmat,raw_var_L5,Highmap,Lowmap,Threshmap_High,Threshmap_Low)

p_mat_triu=Pmat; % initialize
p_mat_triu(tril(true(length(Pmat))))=1;
% for Lowmap
p_mat_Low_triu=Threshmap_Low.*p_mat_triu;
p_mat_Low_triu_fdr=ones(size(Pmat)); % initialize
p_mat_Low_triu_fdr(Threshmap_Low)=spm_P_FDR(p_mat_Low_triu(Threshmap_Low));

% for Highmap
p_mat_High_triu=Threshmap_High.*p_mat_triu;
p_mat_High_triu_fdr=ones(size(Pmat)); % initialize
p_mat_High_triu_fdr(Threshmap_High)=spm_P_FDR(p_mat_High_triu(Threshmap_High));

p_cell_Low=cell(6,0); % intialize
p_cell_High=p_cell_Low;% intialize

for m=1:length(Pmat)
    idx_Low=find(p_mat_Low_triu_fdr(m,:)<0.05);
    if ~isempty(idx_Low)
        for i =1:length(idx_Low)
            p_cell_Low(1,end+1)={[char(raw_var_L5(m))]};
            p_cell_Low(2,end)={[char(raw_var_L5(idx_Low(i)))]};
            p_cell_Low(3,end)={['HAN=',num2str(Highmap(m,idx_Low(i)))]};
            p_cell_Low(4,end)={['LAN=',num2str(Lowmap(m,idx_Low(i)))]};
            p_cell_Low(5,end)={p_mat_Low_triu_fdr(m,idx_Low(i))};
            p_cell_Low(6,end)={Lowmap(m,idx_Low(i))};
        end
    end
end

for m=1:length(Pmat)
    idx_High=find(p_mat_High_triu_fdr(m,:)<0.05);
    if ~isempty(idx_High)
        for i =1:length(idx_High)
            p_cell_High(1,end+1)={[char(raw_var_L5(m))]};
            p_cell_High(2,end)={[char(raw_var_L5(idx_High(i)))]};
            p_cell_High(3,end)={['HAN=',num2str(Highmap(m,idx_High(i)))]};
            p_cell_High(4,end)={['LAN=',num2str(Lowmap(m,idx_High(i)))]};
            p_cell_High(5,end)={p_mat_High_triu_fdr(m,idx_High(i))};
            p_cell_High(6,end)={Highmap(m,idx_High(i))};
        end
    end
end

num_Low=size(p_cell_Low,2);
num_High=size(p_cell_High,2);

[~,idx_Low]=sort(cell2mat(p_cell_Low(6,:)),'descend');
p_cell_Low=p_cell_Low(:,idx_Low);

[~,idx_High]=sort(cell2mat(p_cell_High(6,:)),'descend');
p_cell_High=p_cell_High(:,idx_High);

p_cell_High(6,:)=[];
p_cell_Low(6,:)=[];