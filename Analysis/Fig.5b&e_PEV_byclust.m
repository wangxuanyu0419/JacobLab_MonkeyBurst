% plot MUA_PEV by clusters
clear; close all; clc;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/PEVspatial/PEVspt.mat','PEVspt');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/T.mat','T');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat';
%% Plot
grey = ones(1,3).*0.5; cb = 'gbrk';
close all; fig = figure('Position',[0 0 800 300]);
% yl = [-1,3];
xl = [-0.5,3.2];
ianm = "W"; yl = [-1,8];
% for ianm = ["R","W"]
    clf(fig,'reset');
    n = T.(ianm).nclust;
    [~,loc_id] = cellfun(@(l) ismember(l,PEVspt.(ianm).loc_list,'rows'),PEVspt.(ianm).location);
    for icond = ["samp","dist"]
        [~,ic] = ismember(icond,["samp","dist"]);
        subplot(1,2,ic); hold on;
        fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        for i = 1:n
            locs = find(T.(ianm).lbl==i);
            locsel = ismember(loc_id,locs);
            data = PEVspt.(ianm).(icond)(locsel,:);
            fill([PEVspt.tds,fliplr(PEVspt.tds)],[mean(data,'omitnan')+ste(data),fliplr(mean(data,'omitnan')-ste(data))],cb(i),'EdgeColor','none','FaceAlpha',0.3,'HandleVisibility','off');
            plot(PEVspt.tds,mean(data,'omitnan'),cb(i),'LineWidth',1);
        end
        ylim(yl);
        xlim(xl); % xlabel('Time from sample onset [s]');
        set(gca,'TickDir','out');
        title(icond); legend('boxoff');
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('PEV_byclust_%s',ianm)),'-dpng');
    print(fullfile(outf,sprintf('PEV_byclust_%s',ianm)),'-dpdf','-r0','-bestfit');
% end