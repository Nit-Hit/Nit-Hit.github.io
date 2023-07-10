%-----------------------------------------------------------------------
% Chenfei Ye 03/17/2018
% update: change back to both groups
% update: only based on AP group
% This script is designed for calculating correlation between each parcel
% and amyloid
% ------cye7@jhu.edu
function stat_parcel=par_test(num,raw_var,amyloid,topnum,HighAmyIndex,LowAmyIndex,ID)

   
        corr_parcel=cell(topnum+1,4);
        corr_parcel(1,1)={'Parcel'};
        corr_parcel(1,2)={'R: correlation with amyloid'};
        corr_parcel(1,3)={'pValue for correlation'};
        corr_parcel(1,4)={'pValue for correlation after FDR'};
        par_corr=cell(length(raw_var),3);
        par_corr(:,1)=raw_var';
        %amyloid=amyloid(HighAmyIndex);  % update:only based on AP group
        for i = 1: length(raw_var)
            [r,p]=corr(amyloid,num(:,i));   % update:for all subject group
            par_corr(i,2)={r};
            par_corr(i,3)={p};
        end
        [abs_corr,idx]=sort(abs(cell2mat(par_corr(:,2))),'descend');
        corr_parcel(2:end,1:3)=par_corr(idx(1:topnum),:);
        corr_parcel(2:end,4)=num2cell(spm_P_FDR(cell2mat(corr_parcel(2:end,3))));
        stat_parcel.corr_parcel=corr_parcel;

        ttest_result_raw=cell(size(num,2),4);
        ttest_result_raw(:,1)=raw_var';
        p_raw=zeros(size(num,2),1);
        for i = 1:size(num,2)
            [~,p] = ttest2(num(HighAmyIndex,i),num(LowAmyIndex,i));
            p_raw(i)=p;
            ttest_result_raw(i,2)={['pValue:',num2str(p)]};
            ttest_result_raw(i,3)={['HighMean:',num2str(mean(num(HighAmyIndex,i)))]};
            ttest_result_raw(i,4)={['LowMean:',num2str(mean(num(LowAmyIndex,i)))]};
        end
        stat_parcel.raw=ttest_result_raw;
        stat_parcel.num005=length(find(p_raw<0.05));
        stat_parcel.p005=ttest_result_raw(p_raw<0.05,:);
        fdr=spm_P_FDR(p_raw);
        stat_parcel.fdr=ttest_result_raw(fdr<0.05,:);
        stat_parcel.numfdr=length(find(fdr<0.05));
        
        
        h_Parcel_corr=figure;
        subplot(2,2,1);
        x=amyloid;
        y=find(ismember(raw_var,corr_parcel(2,1)));
        scatter(x,num(:,y),20);  % update:for all subject group
        labelpoints(x, num(:,y), ID(:),'outliers_SD',3, 'FontSize', 8, 'Color', 'b'); % update:for all subject group
        lsline;
        xlabel('cDVR');
        ylabel(corr_parcel(2,1));
        title(['R = ',num2str(stat_parcel.corr_parcel{2,2})]);
        hold off
        
        subplot(2,2,2);
        x=amyloid;
        y=find(ismember(raw_var,corr_parcel(3,1)));
        scatter(x,num(:,y),20);  % update:for all subject group
        labelpoints(x, num(:,y), ID(:),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');% update:for all subject group
        lsline;
        xlabel('cDVR');
        ylabel(corr_parcel(3,1));
        title(['R = ',num2str(stat_parcel.corr_parcel{3,2})]);
        hold off
        
        subplot(2,2,3);
        x=amyloid;
        y=find(ismember(raw_var,corr_parcel(4,1)));
        scatter(x,num(:,y),20);  % update:for all subject group
        labelpoints(x, num(:,y), ID(:),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');% update:for all subject group
        lsline;
        xlabel('cDVR');
        ylabel(corr_parcel(4,1));
        title(['R = ',num2str(stat_parcel.corr_parcel{4,2})]);
        hold off
        
        subplot(2,2,4);
        x=amyloid;
        y=find(ismember(raw_var,corr_parcel(5,1)));
        scatter(x,num(:,y),20);  % update:for all subject group
        labelpoints(x, num(:,y), ID(:),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');% update:for all subject group
        lsline;
        xlabel('cDVR');
        ylabel(corr_parcel(5,1));
        title(['R = ',num2str(stat_parcel.corr_parcel{5,2})]);
        hold off
        
        savefig(h_Parcel_corr,['temp\Parcel_corr']);
  
end
        
        
        
        
