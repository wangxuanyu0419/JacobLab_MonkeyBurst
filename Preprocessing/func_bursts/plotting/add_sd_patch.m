function add_sd_patch(l,sd)
nl = numel(l);
sz_sd = size(sd);
if sz_sd(1)<sz_sd(2)
    sd = sd';
end
for i = 1:numel(l)
    x = l(i).XData';
    y = l(i).YData';
    patch(l.Parent,'XData',vertcat(x, flip(x)),'YData',vertcat(y+sd(:,i),flip(y-sd(:,i))),'FaceColor',l(i).Color,'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
end
