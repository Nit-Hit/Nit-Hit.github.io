%-----------------------------------------------------------------------
% Chenfei Ye 03/27/2017
% This script is designed for calculating residual of linear modal
% output: residual matrix
% Reference: https://www.ncbi.nlm.nih.gov/pubmed/16624590
% ------cye7@jhu.edu
function output=residual_test(num,HighAmyIndex,LowAmyIndex)
output=zeros(size(num,2),size(num,2));
for i =1:length(output)
    for j=1:length(output)
        % for highAmy 
        H1_parcel=num(HighAmyIndex,i);
        H2_parcel=num(HighAmyIndex,j);
        foo = fit(H1_parcel,H2_parcel,'poly1');
        output_H = H2_parcel - foo(H1_parcel);
%         fittable = table(H1_parecl,H2_parecl);
%         lm1 = fitlm(fittable,'linear','ResponseVar','H2_parecl');
%         output_H=cell2mat(table2cell(lm1.Residuals(:,1)));
        % for lowAmy
        L1_parcel=num(LowAmyIndex,i);
        L2_parcel=num(LowAmyIndex,j);
%         fittable = table(L1_parecl,L2_parecl);
%         lm2 = fitlm(fittable,'linear','ResponseVar','L2_parecl');
%         output_L=cell2mat(table2cell(lm2.Residuals(:,1)));
        foo = fit(L1_parcel,L2_parcel,'poly1');
        output_L = L2_parcel - foo(L1_parcel);

        % Levene's test
        H_L_type=[zeros(length(output_H),1);ones(length(output_L),1)];
        output(i,j) = vartestn([output_H;output_L],H_L_type,'TestType','LeveneAbsolute','Display','off');
        %output(i,j) = vartestn([output_H;output_L],H_L_type,'TestType','LeveneAbsolute');
    end
end
idx = logical(eye(size(output)));
output(idx)=1;
