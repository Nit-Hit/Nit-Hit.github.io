%-----------------------------------------------------------------------
% Chenfei Ye 03/09/2017
% This script is designed for FDR correction on BIOCARD data
% Output: p_cell  saves significant connectivity
% ------cye7@jhu.edu

function [p_cell,p_cell2]=stat_mat(Pmat,raw_var_L5,Highmap,Lowmap)
p_mat_triu=Pmat; % initialize
p_mat_triu(tril(true(length(Pmat))))=1;
p_cell=cell(length(Pmat),1);
p_cell2=cell(5,0);
for m=1:length(Pmat)
    idx=find(p_mat_triu(m,:)<0.05);
    if ~isempty(idx)
        for i =1:length(idx)
            p_cell(m,i+1)={[char(raw_var_L5(m)),' & ',char(raw_var_L5(idx(i))),' HAN:',num2str(Highmap(m,idx(i))),' LAN:',num2str(Lowmap(m,idx(i))),' P=',num2str(Pmat(m,idx(i)))]}; 
            p_cell2(1,end+1)={[char(raw_var_L5(m))]};
            p_cell2(2,end)={[char(raw_var_L5(idx(i)))]};
            p_cell2(3,end)={['HAN=',num2str(Highmap(m,idx(i)))]};
            p_cell2(4,end)={['LAN=',num2str(Lowmap(m,idx(i)))]};
            p_cell2(5,end)={Pmat(m,idx(i))};
        end
    end
end
p_cell(:,1)=raw_var_L5';

[~,idx]=sort(cell2mat(p_cell2(5,:)));
p_cell2=p_cell2(:,idx);


