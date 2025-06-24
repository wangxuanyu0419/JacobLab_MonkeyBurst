% plot granger causality (intra- and inter-regional) by PFC modules
clc; clear; close all;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/26.connectivity';
load(fullfile(inf,'con_sum'),'con_sum','freq');
load(fullfile(inf,'con_sort'),'con_sort');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/granger'; mkdir(outf);
%% Plot inter-regional with log-scale frequency, stacked
close all; fig = figure('Position',[0 0 250 500]);
c = 'rbgm'; fx = 5; tsel = freq>=(50-fx) & freq<=(50+fx);
for ianm = ["R","W"]
    clf(fig,'reset');
    switch ianm
        case 'R'; yl = [0 0.02];
        case 'W'; yl = [0 0.04];
    end
    n = con_sort.(ianm).nclust;
    for icond = ["granger_PFC2VIP","granger_VIP2PFC"]
        switch icond
            case 'granger_PFC2VIP'; subplot(2,1,1); hold on;
            case 'granger_VIP2PFC'; subplot(2,1,2); hold on;
        end
        for x = 1:n
            d = con_sort.(ianm).(icond).mean(x,:);
            d(tsel) = nan;
            i = 1:numel(d);
            d(isnan(d)) = interp1(i(~isnan(d)), d(~isnan(d)), i(isnan(d)), 'linear');
            m = smoothdata(d,'gaussian',5);
            e = smoothdata(ste(con_sort.(ianm).(icond).pool{x}),'gaussian',5);
%             e(tsel) = nan;
%             e(isnan(e)) = interp1(i(~isnan(e)), e(~isnan(e)), i(isnan(e)), 'linear'); 
            fill([log2(freq(:));flipud(log2(freq(:)))],[m(:)+e(:);flipud(m(:)-e(:))],c(x),'FaceAlpha',0.3,'EdgeColor','none','HandleVisibility','off');
            plot(log2(freq),m,c(x),'DisplayName',sprintf('Clust#%d',x));
            xlim([1,6]); xticks(1:6); xticklabels(2.^(1:6));
            ylim(yl);
            ylabel(icond{1}(9:end),'FontSize',15);
            legend('boxoff');
            set(gca,'TickDir','out');
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('Inter_Connectivity_byclust_%s_stacked',ianm)),'-dpdf','-r0','-bestfit');
    print(fullfile(outf,sprintf('Inter_Connectivity_byclust_%s_stacked',ianm)),'-dpng');
end
%% Plot bars for comparing 