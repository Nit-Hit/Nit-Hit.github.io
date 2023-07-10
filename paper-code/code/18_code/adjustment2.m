%-----------------------------------------------------------------------
% Chenfei Ye 03/20/2019
% This script is designed for confounding adjustment (use coefficients from all subjects to model GLM)
% Input:
% num: raw_data matrix, type:double, #row=#subjects, #column=#features
% ID: subjects ID vector, type:cell, #row=#subjects
% LowAmyIndex: index for Lowamyloid subjects vector, type:double, #row=#subjects with Lowamyloid
% Output:
% output: adjusted_data matrix, type:double, #row=#subjects, #column=#features
% Coeff: linear coefficients structure, type: structure
% ------cye7@jhu.edu
function [output,Coeff]=adjustment2(num,ID,LowAmyIndex)
[~, ~, raw_demo]=xlsread('E:\cye_code\BIOCARD_matrix\matrix\demo_20jan17.xlsx'); % read demographic info
name_demo=raw_demo(:,2);

[~,~,ib]=intersect(ID,name_demo,'stable'); %  C = A(ia) and C = B(ib).
for i= 1: length(ID)
    raw_demo2(i,:)=raw_demo(ib(i),:);
end

dirs=dir('H:\MT_jhu\BIOCARDII_DTI' ); 
dircell=struct2cell(dirs)' ;
filenames=dircell(:,1) ;
filenames(1:2,:)=[];
filenames_part=cellfun(@(x) strsplit(x,'_'),filenames,'UniformOutput',false );
filenames_part=reshape([filenames_part{:}],4,[])';
[C,~,ib]=intersect(ID,filenames_part(:,3),'stable'); %  C = A(ia) and C = B(ib).
scanYear=zeros(length(C),1);
for i =1:length(ID)
    scanParPath=ls(['H:\MT_jhu\BIOCARDII_DTI',filesep,strtrim(char(filenames(ib(i)))),filesep,'DpfRec',filesep,'*.par']);
    scanParPath=['H:\MT_jhu\BIOCARDII_DTI',filesep,strtrim(char(filenames(ib(i)))),filesep,'DpfRec',filesep,scanParPath(1,:)];
     temp= strsplit(char(importscantime(scanParPath)),'.');
     scanYear(i)=str2num(char(temp(1)));
end
age=scanYear-cell2mat(raw_demo2(:,8));
sex=cell2mat(raw_demo2(:,5))-1;
%edu=cell2mat(raw_demo2(:,10));


% ft_idx=1;
% [h,atab,ctab,stats] = aoctool(num(:,ft_idx),amyloid,age);
% disp(['ANCOVA with covariate age P= ',num2str(cell2mat(atab(4,6)))]);
% return
%% confound regression
    output=num;
    Coeff.Intercep=zeros(1,size(num,2));
    Coeff.X_vec=zeros(1,size(num,2));
    Coeff.age=zeros(1,size(num,2));
    Coeff.sex=zeros(1,size(num,2));
    %Coeff.edu=zeros(1,size(num,2));
for i =1:size(num,2)
    X_vec=num(:,i);
%     X_vec_Low=X_vec(LowAmyIndex);
%     age_Low=age(LowAmyIndex);
%     sex_Low=sex(LowAmyIndex);
    %edu_Low=edu(LowAmyIndex);
    fittable = table(X_vec,age,sex);
   
    %fittable.sex = nominal(fittable.sex);
    lm2 = fitlm(fittable,'linear','ResponseVar','X_vec');
    Coeff.Intercep(i)=cell2mat(table2cell(lm2.Coefficients(1,1)));
    Coeff.age(i)=cell2mat(table2cell(lm2.Coefficients(2,1)));
    Coeff.sex(i)=cell2mat(table2cell(lm2.Coefficients(3,1)));
    %Coeff.edu(i)=cell2mat(table2cell(lm2.Coefficients(4,1)));
    X_vec1=X_vec-Coeff.age(i)*age-Coeff.sex(i)*sex;
 
    output(:,i)=X_vec1;

    % anovan(lm2);
end

