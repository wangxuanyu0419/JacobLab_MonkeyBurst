% plot spike-field coupling results across region (bi-directional)
clear; close all; clc;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat';
load(fullfile(inf,'T'),'T');
P2Vf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_PFC2VIP_byepoch_byloc';
load(fullfile(P2Vf,'SFC_sum'),'SFC_sum');
SFC_sum.PFCchan.T = nan(height(SFC_sum.PFCchan),1);
for i = 1:height(SFC_sum.PFCchan)
    SFC_sum.PFCchan.T(i) = T.(SFC_sum.PFCchan.animal(i)).lbl(SFC_sum.PFCchan.loc_id(i));
end
SFC_sum_P2V = SFC_sum;
V2Pf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_VIP2PFC_byepoch_byloc';
load(fullfile(V2Pf,'SFC_sum'),'SFC_sum');
SFC_sum.PFCchan.T = nan(height(SFC_sum.PFCchan),1);
for i = 1:height(SFC_sum.PFCchan)
    SFC_sum.PFCchan.T(i) = T.(SFC_sum.PFCchan.animal(i)).lbl(SFC_sum.PFCchan.loc_id(i));
end
SFC_sum_V2P = SFC_sum;
clear SFC_sum;
%% plot results: frequency extend, same scale
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
yl = [1,7];
for ianm = ["R","W"]
    switch ianm
        case 'R'; close all; fig = figure('Position',[0 0 1000 600]); cl = [0 8e-3];
        case 'W'; close all; fig = figure('Position',[0 0 1000 800]); cl = [0 15e-3];
    end
    n = T.(ianm).nclust;
    for i = 1:n
        % plot labelled clusters
        subplot(n,5,i*5-4);
        h = plot_dot_byloc(gca,ianm,sprintf('Cluster#%d',i));
        for ic = 1:numel(h)
            if T.(ianm).lbl(ic)==i; h{ic}.FaceColor='r'; end
        end
        set(gca,'xtick',[], 'ytick', []);
        % plot SFC for PFC2VIP and VIP2PFC
        for icond = ["PFC2VIP","VIP2PFC"]
            switch icond
                case 'PFC2VIP'
                    subplot(n,5,i*5-[3,2]);
                    anmsel = SFC_sum_P2V.PFCchan.animal==(char(ianm));
                    data = SFC_sum_P2V.ppc0(anmsel,:,:);
                    lbl = SFC_sum_P2V.PFCchan.T(anmsel);
               case 'VIP2PFC'
                    subplot(n,5,i*5-[1,0]);
                    anmsel = SFC_sum_V2P.PFCchan.animal==(char(ianm));
                    data = SFC_sum_V2P.ppc0(anmsel,:,:);
                    lbl = SFC_sum_V2P.PFCchan.T(anmsel);
           end
           hold on;
           d = squeeze(mean(data(lbl==i,:,:),'omitnan'));
           imagesc(SFC_sum_P2V.time,log2(SFC_sum_P2V.freq),d);
           set(gca,'YDir','normal'); %clim(cl);
           colormap(jet);
           arrayfun(@(x) plot(x*ones(1,2),yl,'--w'),[0,0.5,1.5,2,3]);
           ax = gca;
           ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
           xlim([-0.5,3.2]);
           ylabel('Frequency [Hz]'); yticks(1:7); yticklabels(2.^(1:7));
           ylim(yl);
           clim(cl);
           title(icond);
           cb = colorbar; cb.Label.String = 'ppc';
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outfigf,sprintf('SFC_interreg_by%dclust_%s_summary',n,ianm)),'-dpdf','-r0','-bestfit');
    print(fullfile(outfigf,sprintf('SFC_interreg_by%dclust_%s_summary',n,ianm)),'-dpng');
end