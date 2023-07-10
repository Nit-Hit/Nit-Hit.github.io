%-----------------------------------------------------------------------
% Chenfei Ye 02/09/2017
% This script is designed for boxplot dots
% ------cye7@jhu.edu
function dots_boxplot(Highmap,Lowmap,R2_threshold,raw_var,HighAmyIndex,LowAmyIndex,num)

%% calculate survival dots after filtering
diff_threshold=0.3;
idx_onlyHigh=find((Highmap>R2_threshold)&(Highmap-Lowmap)>diff_threshold); % index of Highmap>threshold
idx_onlyLow=find((Lowmap>R2_threshold)&(Lowmap-Highmap)>diff_threshold); % index of Lowmap>threshold

hold on;
row_onlyHigh=ceil(idx_onlyHigh/length(Highmap));
col_onlyHigh=mod(idx_onlyHigh,length(Highmap));
row_onlyLow=ceil(idx_onlyLow/length(Lowmap));
col_onlyLow=mod(idx_onlyLow,length(Lowmap));

plot(row_onlyHigh,col_onlyHigh,'ro','MarkerSize',10,'linewidth',3);
plot(row_onlyLow,col_onlyLow,'ko','MarkerSize',10,'linewidth',3);
hold off;

if nargin~=7
    return
end
% boxplot only in Highmap
G=cell(size(num,1),1);
G(HighAmyIndex)={'HighAmyIndex'};
G(LowAmyIndex)={'LowAmyIndex'};


for i = 1:length(idx_onlyHigh)
    logratio_value(:,1)=log(num(:,row_onlyHigh(i))./num(:,col_onlyHigh(i)));
    figure;
    boxplot(logratio_value,G);
    str1=char(raw_var(row_onlyHigh(i))); % name of parcel
    str2=char(raw_var(col_onlyHigh(i))); % name of parcel
    title(['boxplot of ',str1,' and ',str2,' Basethresh=',num2str(R2_threshold),' diffthresh=',num2str(diff_threshold)])
    if strfind(str1,'/')
        str1(strfind(str1,'/'))='.';
    end
    if strfind(str2,'/')
        str2(strfind(str2,'/'))='.';
    end
    saveas(gcf,['boxplot_Highdot_',str1,'_',str2,'.jpg'])
end


for i = 1:length(idx_onlyLow)
    logratio_value(:,1)=log(num(:,row_onlyLow(i))./num(:,col_onlyLow(i)));
    figure;
    boxplot(logratio_value,G);
    str1=char(raw_var(row_onlyLow(i))); % name of parcel
    str2=char(raw_var(col_onlyLow(i))); % name of parcel
    title(['boxplot of ',str1,' and ',str2,' Basethresh=',num2str(R2_threshold),' diffthresh=',num2str(diff_threshold)])
    if strfind(str1,'/')
        str1(strfind(str1,'/'))='.';
    end
    if strfind(str2,'/')
        str2(strfind(str2,'/'))='.';
    end
    saveas(gcf,['boxplot_Lowdot_',str1,'_',str2,'.jpg'])
end
