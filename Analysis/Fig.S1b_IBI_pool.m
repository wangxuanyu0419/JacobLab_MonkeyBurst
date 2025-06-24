% Plot pooled Inter-burst interval distribution
clear; close all; clc;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/6.BurstSeq/IBI';
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
load(fullfile(inf,'IBI_sum_inchan'),'IBI_sum');
%% Plot results
close all;
c = 'brg'; nbin = 40;
fig = figure('Position',[100 100 800 250]);
for iband = ["Beta","LowGamma","HighGamma"]
    [~,ib] = ismember(iband,["Beta","LowGamma","HighGamma"]);
    switch iband
        case 'Beta'; x0 = 0.1; cb = 'b';
        case 'LowGamma'; x0 = 0.4; cb = 'r';
        case 'HighGamma'; x0 = 0.7; cb = 'g';
    end
    ax = axes(fig,'Position',[x0,0.18,0.24,0.68]); hold on;
    data = vertcat(IBI_sum.(iband){:});
    histogram(data,linspace(0,200,nbin+1),'FaceColor',c(ib),'HandleVisibility','off');
    m1 = mode(data(data<=20));
    yl = ylim(); plot(m1*[1 1],yl,'--k','DisplayName',sprintf('mode1 = %d',m1));
    m2 = mode(data(data>20));
    plot(m2*[1 1],yl,'--k','DisplayName',sprintf('mode2 = %d',m2));
    xlim([0 160]);
    ylabel('Count'); title(iband,'Color',c(ib));
    legend('box','off','FontSize',5);
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'IBI_pool'),'-depsc');
print(fullfile(outfigf,'IBI_pool'),'-dpng');
