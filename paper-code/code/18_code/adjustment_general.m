%-----------------------------------------------------------------------
% Chenfei Ye 08/11/2017
% This script is designed for confounding adjustment
% Input:
% vol: volume matrix, type:double, #row=#subjects, #column=#parcels
% age: age vector, type:double, #row=#subjects, #column=1
% sex: sex vector, type:double(integer) or cell(string), #row=#subjects, #column=1
% group: group type vector, type:double(integer) or cell(string), #row=#subjects, #column=1
% Output:
% output: adjusted volume matrix, type:double, #row=#subjects, #column=#parcels
% Coeff: linear coefficients structure, type: structure
% reference method: Dukart J, Schroeter M L, Mueller K, et al. Age correction in dementia¨Cmatching to a healthy brain[J]. PloS one, 2011, 6(7): e22193.
% ------cye7@jhu.edu
function [output,Coeff]=adjustment(vol,age,sex,group)

% initialzie
    output=vol;
    Coeff.Intercep=zeros(1,size(vol,2));
    Coeff.volume=zeros(1,size(vol,2));
    Coeff.age=Coeff.volume;
    Coeff.sex=Coeff.volume;
    Coeff.group=Coeff.volume;
for i =1:size(vol,2)
    vol_eachColumn=vol(:,i);
    sex=grp2idx(sex);
    group=grp2idx(group);
    fittable = table(vol_eachColumn,age,sex);
    % transform categorical variable to dummy variable
    fittable.sex = nominal(fittable.sex);
    fittable.group = nominal(fittable.group);
    % linear modeling
    lm2 = fitlm(fittable,'linear','ResponseVar','vol_eachColumn');
    % save coefficents and output
    Coeff.Intercep(i)=cell2mat(table2cell(lm2.Coefficients(1,1)));
    Coeff.age(i)=cell2mat(table2cell(lm2.Coefficients(2,1)));
    Coeff.sex(i)=cell2mat(table2cell(lm2.Coefficients(3,1)));
    Coeff.group(i)=cell2mat(table2cell(lm2.Coefficients(4,1)));
    output(:,i)=vol_eachColumn-Coeff.age(i)*age-Coeff.sex(i)*sex-Coeff.group(i)*group;
 
end

