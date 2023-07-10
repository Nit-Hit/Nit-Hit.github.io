%-----------------------------------------------------------------------
% Chenfei Ye 05/01/2017
% This script is designed to change num and raw_var from L5 to L4
% ------cye7@jhu.edu
function [num,raw_var_L4]=Level4(num,raw_var,img_modal)
matrix_path='C:\Users\susumulab\Desktop\cye_code\BIOCARD_matrix\matrix\';
[~, ~,lookuptable]=xlsread('C:\Users\susumulab\Desktop\BIOCARD_test\BIOCARD_lookupTable_ko.xlsx'); % read L3-L5 mapping
wholebrainList=[1:26,29:32,35:46,49:82,84:91,93:102,113:148,151:170,173:244,253:266]; % from ACR_L, ACR_R, ....


switch img_modal
    case 1
        % switch the parcel name from L5 to L4
        [~,Locb] = ismember(raw_var,lookuptable(2:end,2));
        [C, ia, ic] = unique(lookuptable(Locb+1,3),'stable');   % C = A(ia) and A = C(ic).
        C=C';
        D=zeros(size(num,1),length(C));
        
        % sum num from L5 to L4
        for i=1:length(C)
            D(:,i)=sum(num(:,(ic==i)),2);
        end
        raw_var_L4=C;
        num=D;
        
        
    case {2,3,4,5,6}
        % read volume matrix
        [num_vol, ~, raw_vol]=xlsread([matrix_path,'Summary_Level5_Type1_filtered_T1combine_LV_flair2.xlsx'],'Sheet1'); % read excel matrix
        raw_vol=raw_vol(2,2:end);
        
        
        % intersection of volume parcel name and parcel name from other modalities
        [raw_intersect,ia,ib]=intersect(raw_var,raw_vol,'stable'); %  C = A(ia) and C = B(ib).
        if ~isequal(raw_intersect,raw_var)
            error('Not equal')
        end
        num_vol=num_vol(:,ib);
        % multiply vol and intensity of other modality
        L5mat_multiply=num_vol.*num;
        
        % switch the parcel name from L5 to L4
        [~,Locb] = ismember(raw_var,lookuptable(2:end,2)); 
        [C, ia, ic] = unique(lookuptable(Locb(2:end)+1,3),'stable');  % C = A(ia) and A = C(ic).
        C=C';
        D=zeros(size(num_vol,1),length(C));
        E=D;
        % sum num from L5 to L4
        for i=1:length(C)
            D(:,i)=sum(num_vol(:,ic==i),2);
            E(:,i)=sum(L5mat_multiply(:,ic==i),2);
        end
        F=E./D;
        
        raw_var_L4=C;
        num=F;
        
end


