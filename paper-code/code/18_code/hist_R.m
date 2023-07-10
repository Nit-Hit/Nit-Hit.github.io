%-----------------------------------------------------------------------
% Chenfei Ye 02/09/2017
% This script is designed for ploting histogram for R and R^2
% ------cye7@jhu.edu
function [pvalue_R_hist]=hist_R(Highmap,Lowmap,img_name,SaveType)
Allmap=[Highmap;Lowmap];
% generate histogram for R and R^2
hist_map(1)=figure;
%subplot(1,2,1);
histogram(Lowmap(:),50);
%text(-0.5,200,['Percent>0.5: ',mat2str(round(100*nnz(Lowmap>0.5)/numel(Lowmap))),'%']);
title([img_name,' for LAN']);
xlim([min(Allmap(:)),max(Allmap(:))]);

%subplot(1,2,2);
hist_map(2)=figure;
histogram(Highmap(:),50);
xlim([min(Allmap(:)),max(Allmap(:))]);

%text(-0.5,200,['Percent>0.5: ',mat2str(round(100*nnz(Highmap>0.5)/numel(Highmap))),'%']);
title([img_name,' for HAN']);


% Two-sample Kolmogorov-Smirnov test
[~,pvalue_R_hist]=kstest2(Lowmap(:),Highmap(:));



if SaveType
    savefig(hist_map,['temp\',['Histogram for ',img_name]]);
end