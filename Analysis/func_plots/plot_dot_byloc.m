function h = plot_dot_byloc(ax,ianm,tl)
% this function creates a location window for further plotting
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';
load(fullfile(inf,'AvgBrstSpatial'),'AvgBrstSpatial');
% load bg
[bg,~,~] = imread(fullfile(inf,sprintf('%s_loc_bg.png',ianm)));
xl = [-7,4]; yl = [-6,5];
axes(ax); hold on;
title(tl);
set(ax,'TickDir','out');
xlim(xl); ylim(yl);
% plot background
ylx = fliplr(yl);
ylx(1) = yl(1) + diff(yl)*size(bg,1)/size(bg,2);
imagesc(xl,ylx,bg,'AlphaData',0.5);
h = get_chan_layout(gca,mat2cell(AvgBrstSpatial.(ianm).loc_list,ones(size(AvgBrstSpatial.(ianm).loc_list,1),1)));
end