%-----------------------------------------------------------------------
% Chenfei Ye 02/09/2017
% This script is designed for plot dots
% ------cye7@jhu.edu
function dots_plot_fix(Highmap,Lowmap,R2_threshold,raw_var,amyloid,num)


%% calculate survival dots after filtering

idx_Highmap=find(Highmap>R2_threshold); % index of Highmap>threshold
idx_Lowmap=find(Lowmap>R2_threshold); % index of Lowmap>threshold
idx_both=idx_Highmap(ismember(idx_Highmap,idx_Lowmap));% index of Highmap>threshold and Lowmap>threshold
idx_onlyHigh=idx_Highmap(~ismember(idx_Highmap,idx_Lowmap)); % index of Highmap>threshold and Lowmap<threshold
idx_onlyLow=idx_Lowmap(~ismember(idx_Lowmap,idx_Highmap));% index of Highmap<threshold and Lowmap>threshold

hold on

plot(ceil(idx_onlyHigh/length(Highmap)),mod(idx_onlyHigh,length(Highmap)),'ro','MarkerSize',10,'linewidth',3);
plot(ceil(idx_onlyLow/length(Highmap)),mod(idx_onlyLow,length(Highmap)),'ko','MarkerSize',10,'linewidth',3);
plot(ceil(idx_both/length(Highmap)),mod(idx_both,length(Highmap)),'mo','MarkerSize',5);
hold off;

if nargin~=6
    return
end
% plot correlation map of connection only in Highmap
for i = 1:length(idx_onlyHigh)
    row=ceil(idx_onlyHigh/length(Highmap));
    col=mod(idx_onlyHigh,length(Highmap));
    amyloid(:,2)=log(num(:,row(i))./num(:,col(i)));
    [R,P] = corrcoef(amyloid);
    figure;
    h_fig=scatter(amyloid(:,1),amyloid(:,2),'b','*');
    xlabel('amyloid DVR');
    str1=char(raw_var(row(i))); % name of parcel
    str2=char(raw_var(col(i))); % name of parcel
    title(['logratio correlation of ',str1,' and ',str2,' with R=',num2str(R(1,2)),' p=',num2str(P(1,2))])
    lsline;
    
    if strfind(str1,'/')
        str1(strfind(str1,'/'))='.';
    end
    if strfind(str2,'/')
        str2(strfind(str2,'/'))='.';
    end
    saveas(h_fig,['Highdot_',str1,'_',str2,'.jpg'])
    close(gcf)
end

% plot correlation map of connection only in Lowmap
for i = 1:length(idx_onlyLow)
    row=ceil(idx_onlyLow/length(Highmap));
    col=mod(idx_onlyLow,length(Highmap));
    amyloid(:,2)=log(num(:,row(i))./num(:,col(i)));
    [R,P] = corrcoef(amyloid);
    figure;
    h_fig=scatter(amyloid(:,1),amyloid(:,2),'b','*');
    %xlabel('amyloid DVR');
    str1=char(raw_var(row(i))); % name of parcel
    str2=char(raw_var(col(i))); % name of parcel
    title(['logratio correlation of ',str1,' and ',str2,' with R=',num2str(R(1,2)),' p=',num2str(P(1,2))])
    lsline;
    
    if strfind(str1,'/')
        str1(strfind(str1,'/'))='.';
    end
    if strfind(str2,'/')
        str2(strfind(str2,'/'))='.';
    end
    saveas(h_fig,['Lowdot_',str1,'_',str2,'.jpg'])
    close(gcf)
end
