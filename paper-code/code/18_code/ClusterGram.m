%-----------------------------------------------------------------------
% Chenfei Ye 08/14/2017
% This script is designed for BIOCARD2 matrix clustergram
% functions: generating clustergram based on correlation map
% input: ONLY need to set Group
% output: cg=handle of clustergram
% NOTE: 1. this function is not inserted in ratiolog_matrix.m. Run
% ratiolog_matrix.m first, then manually run this function.
% NOTE: 2. default is down-top cluster structure, Euclidean distance,
% average distance between two clusters
% ------cye7@jhu.edu

%% cluster plotting
label_L3=raw_var_L3;
label_L5=raw_var_L5;
Group='AP';
if strcmp(Group,'AP')
    data=Highmap;
elseif strcmp(Group,'AN')
    data=Lowmap;
end

Title=['Clustergram of ',img_name,' for ',Group];
tree = linkage(data,'average','correlation');
distance=sort(tree(:,3),'descend');
idx_label = cluster(tree,'criterion', 'distance','cutoff',0.6*max(tree(:,3)));
%% plot clustergram based on K
% K=4;
% cg=clustergram(data,'RowLabels',label,'ColumnLabels',label,'Dendrogram',distance(K-1)-eps);

% plot clustergram based on threshold of distance
% cg=clustergram(data,'RowLabels',label_L3,'ColumnLabels',label_L3,'Dendrogram',0.7*max(tree(:,3)));
cg=clustergram(data,'RowLabels',label_L5,'ColumnLabels',label_L5,'Dendrogram',0.6*max(tree(:,3)),'RowPDist','correlation','ColumnPDist','correlation');
addTitle(cg, Title);

% Label saves the hierarchical organization for each parcel
Label=cg.RowLabels;
for i = 1:length(label_L5)
    [~,ic]=ismember(cg.RowLabels(i),label_L5);
    Label(i,2)=num2cell(idx_label(ic));
end


%% parcel_render
% [~,~,lookuptable]=xlsread(['C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\Structures_removed_T1combine_LV.xlsx'],'render'); % read excel matrix
% Label283= load_untouch_nii('C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\brain_template\1_01_V9.hdr');
% mask=zeros(size(Label283.img));
% if LevelType==5.2&&img_modal<8
%     lookuptable2=lookuptable(:,2);
% elseif LevelType==5.2&&img_modal==8
%     lookuptable2=lookuptable(:,1);
% end
% 
% for i =1:max(idx_label)
%     [~,Locb] = ismember(label_L5(idx_label==i),lookuptable2);
%     idxs = arrayfun(@(x) find(Label283.img==x),Locb,'UniformOutput',false);
%     for m=1:length(idxs)
%         mask(idxs{m})=i;
%     end
% end
% 
% Label283.img=mask;
% save_untouch_nii(Label283 , ['clustergram',filesep,'cluster_',img_name,'_',Group,'.hdr']);