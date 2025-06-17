% Plot publication figures for MUA-PEV:
close all
clear

load('/mnt/storage/xuanyu/JacobLabMonkey/data/8.SpikeSorting/MultiChans/multi_mod.mat','multi_mod');
step = 20;
t = -1:1/1000:4;
t_ds = downsample(t,step);
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

% Compute gliding-window Wilcoxon:
win = 200/1000;
alpha95 = 0.05;
alpha99 = 0.01;

for ireg = ["PFC","VIP"]
    for isplit = ["samp","dist"]
        data_sel.(isplit) = multi_mod.(strcat('PEV_',isplit,'_',ireg));
    end
    for icond = ["right","left"]
        p.(ireg).(icond) = arrayfun(@(ti) signrank(nanmean(data_sel.samp(:,t_ds>=(ti-win/2)&t_ds<=(ti+win/2)),2),nanmean(data_sel.dist(:,t_ds>=(ti-win/2)&t_ds<=(ti+win/2)),2),'tail',icond),t_ds);
    end
end

%% Plot the figure
close all
fig = figure('Position',[100 100 800 250]);
grey = ones(1,3).*0.5;
yl = [-0.2 2]; tlim = [-0.5,3.2];
yb = 1.9;

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.1; yt = 0.5;
        case 'VIP'; x0 = 0.6; yt = 0.8;
    end
    ax = axes(fig,'Position',[x0, 0.15, 0.37, 0.7]); hold on;
    fill(ax,[0 0.5 0.5 0],yl([2,2,1,1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    fill(ax,[1.5 2 2 1.5],yl([2,2,1,1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    fill(ax,[3 3.5 3.5 3],yl([2,2,1,1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    
    for isplit = ["samp","dist"]
        switch isplit
            case 'samp'; c = 'b';
            case 'dist'; c = 'r';
        end
        avg = multi_mod.(strcat('PEV_',isplit,'_',ireg,'_avg'));
        ste = multi_mod.(strcat('PEV_',isplit,'_',ireg,'_ste'));
        fill([t_ds,fliplr(t_ds)],[avg+ste,fliplr(avg-ste)],c,'EdgeAlpha',0,'FaceColor',c,'FaceAlpha',0.3);
        plot(t_ds,avg,c,'LineWidth',2);
    end
    
    for icond = ["right","left"]
        switch icond
            case 'right'; c = 'b'; % samp > dist
            case 'left'; c = 'r'; % samp < dist
        end
        scatter(t_ds(p.(ireg).(icond)<alpha95),yb*ones(1,sum(p.(ireg).(icond)<alpha95)),'.',c,'SizeData',30);
        scatter(t_ds(p.(ireg).(icond)<alpha99),yb*ones(1,sum(p.(ireg).(icond)<alpha99)),'.',c,'SizeData',80);
    end

    xlim(tlim); ylim(yl); ylabel('\omega^{2} PEV');
    xlabel('Time from sample onset [s]');
    title(ireg,'FontSize',15)
    text(0.75,yt,sprintf('n = %d',size(multi_mod.(strcat('PEV_samp_',ireg)),1)),'FontSize',10);
end

%%
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
print(fullfile(outfigf,'pev_multi_wilxc'),'-depsc');
print(fullfile(outfigf,'pev_multi_wilxc'),'-dpng');
% print pdf
set(fig,'Units','Inches'); pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(fig,fullfile(outfigf,'pev_multi_wilxc'),'-dpdf','-r0')