% publication figure for ANOVA on spike rate in/out of bursts
close all
clear

load('/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi/EpochxBand_newband_cntspk_alltrl.mat','fr_mat_sum');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

%% Plot barplot with distribution
band_names = {'BT','LG','HG'};
inout = {'in','out'};
c.Beta = 'b'; c.LowGamma = 'r'; c.HighGamma = 'g';

close all
fig = figure('Position',[100 100 400 250]);
for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.12; yl = [0.55,0.75];
        case 'VIP'; x0 = 0.59; yl = [0.6,0.9];
    end
    axes(fig,'Position',[x0,0.1,0.37,0.78]);
    
    d = fr_mat_sum.(strcat(ireg,'s_clr'));
    m = squeeze(nanmean(d)); se = squeeze(nanstd(d)./sqrt(size(d,1)));
    b = bar(m,'LineWidth',0.5); hold on
    b(1).FaceColor = 'r'; b(2).FaceColor = 'b';
    x1 = b(1).XData+b(1).XOffset*ones(size(b(1).XData)); x2 = b(2).XData+b(2).XOffset*ones(size(b(2).XData));
    er = errorbar([x1';x2'],m(:),se(:),'LineWidth',0.75);
    er.Color = 'k';
    er.LineStyle = 'none';
    
    ylim(yl); title(ireg,'FontSize',15);
    xticks(b(1).XData); xticklabels(band_names);
    if strcmp(ireg,'PFC'); ylabel('Average Spike Rate [log(Hz)]'); end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'spk_rate_in_out_alltrl'),'-depsc');
print(fullfile(outfigf,'spk_rate_in_out_alltrl'),'-dpng');

%% compute pair-wise statistics
for ireg = ["PFC","VIP"]
    d = fr_mat_sum.(strcat(ireg,'s_clr')); rep = size(d,1);
    din = squeeze(d(:,:,1)); dout = squeeze(d(:,:,2));
    d = [din(:),dout(:)]; % reshape into 2-way rep ANOVA layout
    [fr_mat_sum.stat.(ireg).p,fr_mat_sum.stat.(ireg).tbl,fr_mat_sum.stat.(ireg).stats] = anova2(d,rep,'off');
end
% both PFC and VIP have significant interaction terms
for ireg = ["PFC","VIP"]
    for iband = 1:3
        [~,fr_mat_sum.stat.posthoc.(ireg).(fr_mat_sum.cfg.band_names{iband})] = ttest(fr_mat_sum.(strcat(ireg,'s_clr'))(:,iband,1),fr_mat_sum.(strcat(ireg,'s_clr'))(:,iband,2));
    end
end