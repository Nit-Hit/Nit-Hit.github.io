%-----------------------------------------------------------------------
% Chenfei Ye 06/05/2017
% This script is designed for scatter plot of most 4 significant
% connections
% ------cye7@jhu.edu
function h=scatter4(num,ID,LowAmyIndex,HighAmyIndex,stat_R,raw_var_L5)

h=figure;
subplot(2,2,1);
x=find(ismember(raw_var_L5,stat_R.fdr_High(1,1)));
y=find(ismember(raw_var_L5,stat_R.fdr_High(2,1)));
scatter(num(LowAmyIndex,x),num(LowAmyIndex,y),20,[1 0 0],'*');
hold on
scatter(num(HighAmyIndex,x),num(HighAmyIndex,y),20,[0 0 1]);
labelpoints(num(LowAmyIndex,x), num(LowAmyIndex,y), ID(LowAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'r');
labelpoints(num(HighAmyIndex,x), num(HighAmyIndex,y), ID(HighAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');
lsline;
xlabel(stat_R.fdr_High(1,1));
ylabel(stat_R.fdr_High(2,1));
hold off

subplot(2,2,2);
x=find(ismember(raw_var_L5,stat_R.fdr_High(1,2)));
y=find(ismember(raw_var_L5,stat_R.fdr_High(2,2)));
scatter(num(LowAmyIndex,x),num(LowAmyIndex,y),20,[1 0 0],'*');
hold on
scatter(num(HighAmyIndex,x),num(HighAmyIndex,y),20,[0 0 1]);
labelpoints(num(LowAmyIndex,x), num(LowAmyIndex,y), ID(LowAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'r');
labelpoints(num(HighAmyIndex,x), num(HighAmyIndex,y), ID(HighAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');
lsline;
xlabel(stat_R.fdr_High(1,2));
ylabel(stat_R.fdr_High(2,2));
hold off

subplot(2,2,3);
x=find(ismember(raw_var_L5,stat_R.fdr_High(1,3)));
y=find(ismember(raw_var_L5,stat_R.fdr_High(2,3)));
scatter(num(LowAmyIndex,x),num(LowAmyIndex,y),20,[1 0 0],'*');
hold on
scatter(num(HighAmyIndex,x),num(HighAmyIndex,y),20,[0 0 1]);
labelpoints(num(LowAmyIndex,x), num(LowAmyIndex,y), ID(LowAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'r');
labelpoints(num(HighAmyIndex,x), num(HighAmyIndex,y), ID(HighAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');
lsline;
xlabel(stat_R.fdr_High(1,3));
ylabel(stat_R.fdr_High(2,3));
hold off

subplot(2,2,4);
x=find(ismember(raw_var_L5,stat_R.fdr_High(1,4)));
y=find(ismember(raw_var_L5,stat_R.fdr_High(2,4)));
scatter(num(LowAmyIndex,x),num(LowAmyIndex,y),20,[1 0 0],'*');
hold on
scatter(num(HighAmyIndex,x),num(HighAmyIndex,y),20,[0 0 1]);
labelpoints(num(LowAmyIndex,x), num(LowAmyIndex,y), ID(LowAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'r');
labelpoints(num(HighAmyIndex,x), num(HighAmyIndex,y), ID(HighAmyIndex),'outliers_SD',3, 'FontSize', 8, 'Color', 'b');
lsline;
xlabel(stat_R.fdr_High(1,4));
ylabel(stat_R.fdr_High(2,4));
hold off