% compute and plot BFC sorted by clusters
clc; clear; close all;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat';
load(fullfile(inf,'T'),'T');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/Burst_peak_phase';
load(fullfile(outf,'MPH_sum_log2_rmERP'),'MPH_sum');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial/AvgBrstSpatial.mat','AvgBrstSpatial');
%% Plot summary: by cluster
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat';
close all; fig = figure('Position',[300 0 600 600]);
n = T.nclust;
PFC = cellfun(@(s) str2double(s(11:12))<9,MPH_sum.label);
for ianm = ["R","W"]
    clf(fig,"reset");
    switch ianm
        case 'R'; cl = [0.05 0.058];
        case 'W'; cl = [0.045 0.07];
    end
    anmsel = cellfun(@(s) s(1)==ianm,MPH_sum.label(PFC));
    [~,loc_id] = cellfun(@(x) ismember(x,AvgBrstSpatial.(ianm).loc_list,'rows'),AvgBrstSpatial.(ianm).location);
    lbl = T.(ianm)(loc_id);
    for iclust = 1:n
        subplot(n,3,3*iclust-2);
        h = plot_dot_byloc(gca,ianm,sprintf('#%d',iclust));
        for i = 1:numel(h)
            if T.(ianm)(i)==iclust; h{i}.FaceColor='r'; end
        end
        set(gca,'XTick',[]); set(gca,'YTick',[]);
        for iband = ["Gamma","Beta"]
            [~,ib] = ismember(iband,["Gamma","Beta"]);
            subplot(n,3,3*iclust-2+ib);
            data = MPH_sum.(iband)(PFC,:,:);
            data = data(anmsel,:,:);
            d = squeeze(mean(data(lbl==iclust,:,:)));
            imagesc(MPH_sum.phase,log2(MPH_sum.freq),d);
            set(gca,'YDir','normal'); clim(cl);
            colormap(jet);
            ax = gca;
            ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
            xlim([-pi,pi]); xticks([-1 -0.5 0 0.5 1]*pi);
            xticklabels([]);
            ylabel('Frequency [Hz]');
            yticks(1:7); yticklabels(2.^(1:7));
            switch iband
                case 'Gamma'
                    ylim([1 6]);
                case 'Beta'
                    ylim([1,4]);
            end
            title(iband);
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outfigf,sprintf('Burst_peak_phase_distribution_by%dclust_%s_log2_rmERP',n,ianm)),'-dpdf','-r0','-bestfit');
    print(fullfile(outfigf,sprintf('Burst_peak_phase_distribution_by%dclust_%s_log2_rmERP',n,ianm)),'-dpng');
end
