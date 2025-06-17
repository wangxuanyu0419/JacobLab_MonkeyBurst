function plot_brst(save_dir,name,br,txt,ylstr,str_legend)
fig = figure('Position',[905 -881 1280 723],'Visible',false);
n_ch = size(br,1);
ax = axes('Position', [0.3 0.11 0.655 0.815]);
l = plot(-1:0.001:3.6,squeeze(mean(br,1)));
sd = std(br,[],1);
add_sd_patch(l,squeeze(sd));
xlabel('time [s]');
ylabel(ylstr);
t = [0 0.5 1.5 2 3];
xlim([-.5 3.1]);
ylim([0 1]);
arrayfun(@(x) line([x x], ylim, 'LineStyle', '--'),t);
legend(str_legend);
tb = annotation('textbox', [0 1 1 0]);
tb.String = txt;
title('mean across channels +- SD')
print(fig, fullfile(save_dir,name),'-depsc')
savefig(fig, fullfile(save_dir,strcat('.',name,'.fig')), 'compact');


c = horzcat(vega10(3), ones(3,1)*0.1);
cla(ax);
hold(ax,'on');
l = cell(3,1);
for i = 1:3
    l{i} = plot(-1:0.001:3.6, squeeze(br(:,i,:)), 'Color', c(i,:));
end
xlabel('time [s]');
ylabel(ylstr);
t = [0 0.5 1.5 2 3];
xlim([-.5 3.1]);
ylim([0 1]);
arrayfun(@(x) line([x x], ylim, 'LineStyle', '--'),t);
legend([l{1}(1) l{2}(1) l{3}(1)],str_legend);
tb = annotation('textbox', [0 1 1 0]);
tb.String = txt;
title('individual electrodes')
print(fig, fullfile(save_dir,strcat(name,'_dist')),'-dpng')
savefig(fig, fullfile(save_dir,strcat('.',name,'_dist.fig')), 'compact');

close(fig);
