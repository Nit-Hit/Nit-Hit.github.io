%-----------------------------------------------------------------------
% Chenfei Ye 03/27/2017
% This script is designed for saving structurized statistical analysis
% Input: Pmat is matrix of pvalue, it must be symmetric
% output: Pmat_fdr is a symmentric pvalue matrix after FDR, note that FDR only
% apply on upper triangle part.
% ------cye7@jhu.edu
function [Pmat_fdr,numfdr]=fdr_mat(Pmat)
Pmat(Pmat==0)=eps;
%Pmat_fdr_triu=ones(length(Pmat));
Pmat_fdr=zeros(length(Pmat)); % within-group correlation map Pvalue
p_matrix_triu=triu(Pmat,1);

p_vec_triu=p_matrix_triu(:);
p_vec_triu(p_vec_triu==0)=[];
fdr = spm_P_FDR(p_vec_triu);% FDR correction
bw=true(length(Pmat));
%Pmat_fdr_triu(triu(bw,1))=fdr;
Pmat_fdr(triu(bw,1))=fdr; 
Pmat_fdr=Pmat_fdr'+Pmat_fdr+eye(length(Pmat_fdr));
numfdr=length(find(fdr<0.05)); % no need to divide by 2
disp('FDR completed')