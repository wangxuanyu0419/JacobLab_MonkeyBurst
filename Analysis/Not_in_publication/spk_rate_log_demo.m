% plot demo for firing rate transformation
close all
clear

load('/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi/EpochxBand_newband_cntspk.mat','fr_mat_sum');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

%%
close all
fig = figure('Position',[0 0 1280 400]);

ax = axes(fig,'Position',[0.1,0.12,0.37,0.8]); hold on;
edges = linspace(0,80,41);
in_mat = fr_mat_sum.all(:,:,:,1);
out_mat = fr_mat_sum.all(:,:,:,2);
histogram(in_mat(:),'BinEdges',edges,'FaceColor','r');
histogram(out_mat(:),'BinEdges',edges,'FaceColor','b');
xlabel('Spike Rate [Hz]'); ylabel('Count of cases');
legend({'in','out'},'FontSize',10)

ax = axes(fig,'Position',[0.57,0.12,0.37,0.8]); hold on;
edges = linspace(-0.6,2,41);
in_mat = cat(1,fr_mat_sum.PFCs_clr(:,:,:,1),fr_mat_sum.VIPs_clr(:,:,:,1));
out_mat = cat(1,fr_mat_sum.PFCs_clr(:,:,:,2),fr_mat_sum.VIPs_clr(:,:,:,2));
histogram(in_mat(:),'BinEdges',edges,'FaceColor','r');
histogram(out_mat(:),'BinEdges',edges,'FaceColor','b');
xlabel('Spike Rate [log10(Hz)]'); ylabel('Count of cases');
legend({'in','out'},'FontSize',10)

set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
print(fullfile(outfigf,'spk_rate_log_demo'),'-depsc');
print(fullfile(outfigf,'spk_rate_log_demo'),'-dpng');
