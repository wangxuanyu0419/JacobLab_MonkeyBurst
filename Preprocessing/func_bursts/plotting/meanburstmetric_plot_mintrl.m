function meanburstmetric_plot_mintrl(fig,mintrl)
% delete patches
delete(findobj(fig, 'Type', 'Patch'));
% recalculate mean and sd
for l = findobj(fig,'Type','Line','-regexp','DisplayName','[^'']')'
    incl = l.UserData.ntrl>=mintrl;
    l.YData = mean(l.UserData.metric(incl,:),1,'omitnan');
    add_sd_patch(l,std(l.UserData.metric(incl,:),[],1,'omitnan'));
end
% move mintrl line
set(findobj(fig,'Tag','mintrl'),'XData',ones(2,1)*mintrl);
