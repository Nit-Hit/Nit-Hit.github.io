%-----------------------------------------------------------------------
% Chenfei Ye 02/08/2017
% This script is designed for sorting parcel name according to matrix excel file, and add level3 name
% ------cye7@jhu.edu
function [raw_var3,num3,raw_var4]=parcel_naming(raw_var,img_modal,num,LevelType)
raw_var2=raw_var;
raw_var3=raw_var;
raw_var4=raw_var;

switch img_modal
    case {1,2,3,4,5,6,7}
        
        if img_modal==1
            [~, ~,raw_remove]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\Structures_removed_T1combine_LV.xlsx','vol'); % read excel matrix
        else
            [~, ~,raw_remove]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\Structures_removed_T1combine_LV.xlsx','others'); % read excel matrix
        end
        
        for i = 1: length(raw_var)
            switch LevelType
                case 5
                    [~,index] = ismember(raw_remove(:,2),raw_var(i));
                case 4
                    [~,index] = ismember(raw_remove(:,4),raw_var(i));
                case 5.2
                    [~,index] = ismember(raw_remove(:,5),raw_var(i));
                case 4.2
                    [~,index] = ismember(raw_remove(:,6),raw_var(i));
            end
            idx=find(index==1);
            raw_var2(i)=raw_remove(idx(1),3); % change to label on Level 3
            raw_var2(i)=cellstr(fliplr(char(raw_var2(i))));% invert the name order of each parcel (Level 3)
        end
        
        [t,idx]=sortrows(raw_var2'); % sort parcel name according after invertion (left/right)
        
        for i = 1: length(raw_var)
            raw_var3(i)=cellstr(fliplr(char(t(i))));% invert the name order of each parcel AGAIN! (Level 3)
            raw_var4(i)=raw_var(:,idx(i));% sort labels (Level 5)
            num3(:,i)=num(:,idx(i));
        end
        
        
        
        
    case 8 % fmri
        [~, ~,raw_remove]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\Structures_removed_T1combine_LV.xlsx','fmri'); % read excel matrix
        for i = 1: length(raw_var)
            
            [~,index] = ismember(raw_remove(:,2),raw_var(i));
            
            idx=find(index==1);
            raw_var2(i)=raw_remove(idx(1),3); % if last variable=3, change to label on Level 3; if last variable=6, change to label on Level 4
            %             raw_var2(i)=raw_remove(index==1,3); % change to label on Level 3
            raw_var2(i)=cellstr(fliplr(char(raw_var2(i))));% invert the name order of each parcel (Level 3)
        end
        
        [t,idx]=sortrows(raw_var2'); % sort parcel name according after invertion (left/right)
        
        for i = 1: length(raw_var)
            raw_var3(i)=cellstr(fliplr(char(t(i))));% invert the name order of each parcel AGAIN! (Level 3)
            raw_var4(i)=raw_var(:,idx(i));% sort labels (Level 5)
            num2(:,i,:)=num(:,idx(i),:);
        end
        
        for i = 1: length(raw_var)
            num3(i,:,:)=num2(idx(i),:,:);
        end
        
end



