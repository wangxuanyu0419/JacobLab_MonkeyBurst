% Compute mean PEV by animal and region
clear; close all; clear;
% Plot MUA PEV by clust
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum');
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
%% Plot figure: sample PEV, three clusters
time = -1:1e-3:4; grey = ones(1,3).*0.5;
tds = downsample(time,20);
ylx = [-0.5,2.5];
close all; fig = figure('Position',[0 0 800 800]);
c.S = 'c';
c.D = 'm';
for anm = ["R","W"]
    [~,ianm] = ismember(anm,["R","W"]);
    anmsel = strcmp(vertcat(ChanSum.animal{:}), anm);
    for reg = ["PFC","VIP"]
        [~,ireg] = ismember(reg,["PFC","VIP"]);
        subplot(2,2,ianm*2-2+ireg); hold on;
        fill(gca,[0 0.5 0.5 0],ylx([2,2,1,1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(gca,[1.5 2 2 1.5],ylx([2,2,1,1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(gca,[3 3.5 3.5 3],ylx([2,2,1,1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        regsel = strcmp(vertcat(ChanSum.region{:}),reg);
        for item = ["S","D"]
            d = vertcat(ChanSum.(strcat("PEV_",item)){anmsel & ChanSum.valid & regsel});
            avg = nanmean(d);
            ste = nanstd(d)./sqrt(size(d,1));
            fill([tds,fliplr(tds)],[avg+ste,fliplr(avg-ste)],c.(item),'EdgeAlpha',0,'FaceColor',c.(item),'FaceAlpha',0.3,'HandleVisibility','off');
            plot(tds,avg,c.(item),'LineWidth',1,'DisplayName',item);
            ylim(ylx); xlim([-0.5,3.2]);
            xlabel('Time from sample onset [s]');
            ylabel('MUA PEV'); legend('boxoff');
            title(sprintf("Monkey %s %s, n = %d",anm,reg, size(d,1)));
            set(gca,'TickDir','out');
            set(gca,'TickLength',[0.05,0.05]);
        end
    end
end
set(fig, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(fig, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
% print(fullfile(outfigf,'MUA_PEV_byanm'),'-dpng');
% print(fullfile(outfigf,'MUA_PEV_byanm'),'-dpdf','-r0','-bestfit');
