%-----------------------------------------------------------------------
% Chenfei Ye 02/08/2017
% This script is designed to plot colormap
% ------cye7@jhu.edu
function h=colormap_plot(map,img_name,title_name,text_label,xtick,LevelType,colorbarrange)

h=figure;
imagesc(map);
h1=colorbar;
if nargin==7
    set(h1, 'ylim', colorbarrange);
elseif nargin==6
    set(h1, 'ylim', [min(map(:)),max(map(:))]);
end
title([title_name,' for ', img_name]);
if strcmp(img_name,'Volume')
    for k=1:length(text_label)
        switch LevelType
            case 5
                text((xtick(k+1)-xtick(k))/2+xtick(k),269,char(text_label(k)),'rotation',-90);
                text(-35,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
            case 4
                text((xtick(k+1)-xtick(k))/2+xtick(k),138,char(text_label(k)),'rotation',-90);
                text(-15,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
            case 5.2
                text((xtick(k+1)-xtick(k))/2+xtick(k),198,char(text_label(k)),'rotation',-90);
                text(-30,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
            case 4.2
                text((xtick(k+1)-xtick(k))/2+xtick(k),71,char(text_label(k)),'rotation',-90);
                text(-10,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
        end
    end
    
elseif strcmp(img_name,'fmri')
    for k=1:length(text_label)
        text((xtick(k+1)-xtick(k))/2+xtick(k),80,char(text_label(k)),'rotation',-90);
        text(-8,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
    end
    
    
else
    for k=1:length(text_label)
        switch LevelType
            case 5
                text((xtick(k+1)-xtick(k))/2+xtick(k),242,char(text_label(k)),'rotation',-90);
                text(-35,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
            case 4
                text((xtick(k+1)-xtick(k))/2+xtick(k),112,char(text_label(k)),'rotation',-90);
                text(-15,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
            case 5.2
                text((xtick(k+1)-xtick(k))/2+xtick(k),168,char(text_label(k)),'rotation',-90);
                text(-25,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
            case 4.2
                text((xtick(k+1)-xtick(k))/2+xtick(k),45,char(text_label(k)),'rotation',-90);
                text(-6,(xtick(k+1)-xtick(k))/2+xtick(k),char(text_label(k)));
        end
    end
end
set(gca, 'xtick', xtick);
set(gca, 'ytick', xtick);
set(gca,'tickdir','out');
set(gca,'xticklabel',' ');
set(gca,'yticklabel',' ');
colormap('jet');

% if SaveType
%     savefig(['temp\',title_name]);
% end