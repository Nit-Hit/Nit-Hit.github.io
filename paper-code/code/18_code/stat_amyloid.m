% Chenfei Ye 04/26/2017
% This script is designed for amyloid correlation
% Output: p_cell  saves significant connectivity
% Output: p_cell2  saves significant connectivity after fdr
% ------cye7@jhu.edu

function [p_cell,p_cell2]=stat_amyloid(ZratiologLow,ZratiologHigh,raw_var_L5,amyloid,LowAmyIndex,HighAmyIndex)
ZratiologAll=zeros(length(amyloid),size(ZratiologLow,2),size(ZratiologLow,3));
ZratiologAll(LowAmyIndex,:,:)=ZratiologLow;
ZratiologAll(HighAmyIndex,:,:)=ZratiologHigh;
p=zeros(size(ZratiologLow,2),size(ZratiologLow,3));
r=p;

for i = 1:size(ZratiologLow,2)
    for j=1:size(ZratiologLow,3)
        [r(i,j),p(i,j)]=corr(amyloid,ZratiologAll(:,i,j));
    end
end

r(logical(eye(length(r)))) = 0;
p(logical(eye(length(p)))) = 1;

% no fdr
p_triu=p; % initialize
p_triu(tril(true(length(p))))=1;
p_cell=cell(4,0);
p_survival=[];
for m=1:length(p)
    idx=find(p_triu(m,:)<0.05);
    if ~isempty(idx)
        for i =1:length(idx)
            p_cell(1,end+1)={[char(raw_var_L5(m))]};
            p_cell(2,end)={[char(raw_var_L5(idx(i)))]};
            p_cell(3,end)={['R=',num2str(r(m,idx(i)))]};
            p_cell(4,end)={['P=',num2str(p(m,idx(i)))]};
            p_survival(end+1)=p(m,idx(i));
        end
    end
end



% with fdr
[P_fdr,numfdr]=fdr_mat(p);
p_fdr_triu=P_fdr; % initialize
p_fdr_triu(tril(true(length(P_fdr))))=1;
p_cell2=cell(4,0);
p_survival2=[];
for m=1:length(P_fdr)
    idx=find(p_fdr_triu(m,:)<0.05);
    if ~isempty(idx)
        for i =1:length(idx)
            p_cell2(1,end+1)={[char(raw_var_L5(m))]};
            p_cell2(2,end)={[char(raw_var_L5(idx(i)))]};
            p_cell2(3,end)={['R=',num2str(r(m,idx(i)))]};
            p_cell2(4,end)={['P=',num2str(P_fdr(m,idx(i)))]};
            p_survival2(end+1)=P_fdr(m,idx(i));
        end
    end
end


[p_ascend,idx_p]=sort(p_survival,'ascend');
[p_ascend2,idx_p2]=sort(p_survival2,'ascend');
p_cell=p_cell(:,idx_p);
p_cell2=p_cell2(:,idx_p2);

