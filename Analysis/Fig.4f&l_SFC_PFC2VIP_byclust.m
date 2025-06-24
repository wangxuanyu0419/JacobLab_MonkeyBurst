% compute and plot PFC spike to VIP field coupling sorted by covmat
% clusters
clc; clear; close all;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat';
load(fullfile(inf,'T'),'T');
%% SFC_byepoch
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_PFC2VIP_byepoch_byloc';
load(fullfile(outf,'SFC_sum'),'SFC_sum');
SFC_sum.PFCchan.T = nan(height(SFC_sum.PFCchan),1);
for i = 1:height(SFC_sum.PFCchan)
    SFC_sum.PFCchan.T(i) = T.(SFC_sum.PFCchan.animal(i)).lbl(SFC_sum.PFCchan.loc_id(i));
end
save(fullfile(outf,'SFC_sum'),'SFC_sum');
%% plot results
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat';
yl = [1,6];
for ianm = ["R","W"]
    n = T.(ianm).nclust;
    switch ianm
        case 'R'
            close all; fig = figure('Position',[300 0 600 600]);
            cl = [0 0.008];
        case 'W'
            close all; fig = figure('Position',[300 0 600 600]);
            cl = [0 0.015];
    end
    anmsel = SFC_sum.PFCchan.animal==(char(ianm));
    data = SFC_sum.ppc0(anmsel,:,:);
    lbl = SFC_sum.PFCchan.T(anmsel);
    for iclust = 1:n
        subplot(n,3,3*iclust-2);
        h = plot_dot_byloc(gca,ianm,sprintf('#%d',iclust));
        for i = 1:numel(h)
            if T.(ianm).lbl(i)==iclust; h{i}.FaceColor='r'; end
        end
        set(gca,'XTick',[]); set(gca,'YTick',[]);
        subplot(n,3,3*iclust+[-1,0]); hold on;
        d = squeeze(mean(data(lbl==iclust,:,:),'omitnan'));
        imagesc(SFC_sum.time,log2(SFC_sum.freq),d);
        set(gca,'YDir','normal'); clim(cl);
        colormap(jet);
        arrayfun(@(x) plot(x*ones(1,2),yl,'--w'),[0,0.5,1.5,2,3,3.5]);
        ax = gca;
        ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
        xlim([-0.5,3.2]);
        ylabel('Frequency [Hz]'); yticks(1:7); yticklabels(2.^(1:7));
        ylim(yl);
        title('PFC-VIP SFC');
        cb = colorbar; cb.Label.String = 'ppc';
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outfigf,sprintf('PFC2VIP_SFC_by%dclust_%s_log2_rmERP',n,ianm)),'-dpdf','-r0','-bestfit');
    print(fullfile(outfigf,sprintf('PFC2VIP_SFC_by%dclust_%s_log2_rmERP',n,ianm)),'-dpng');
end
