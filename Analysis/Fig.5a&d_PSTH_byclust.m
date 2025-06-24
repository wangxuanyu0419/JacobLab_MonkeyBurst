% plot normalized PSTH
clc; clear; close all;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/T','T');
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_PFC2VIP_byepoch_byloc';
load(fullfile(inf,'SFC_sum'),'SFC_sum'); % load SFC_sum file
multf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/003.MultiUnit';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi/multi_mod.mat','multi_mod');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/PSTH_byclust';
time = -1:1e-3:4;
%% Plot
close all; fig = figure('Position',[0 0 400 300]);
ylx = [-0.5,1.5]; cb = 'gbrk';
bl = [-0.5,0]; grey = ones(1,3).*0.5;
xl = [-0.5,3.2];
t_bl = time>=bl(1)&time<bl(2);
ianm = "W";
% for ianm = ["R","W"]
    clf(fig,'reset'); hold on;
    arrayfun(@(x) plot(x*ones(1,2),ylx,'--k','HandleVisibility','off'),[0,0.5,1.5,2,3,3.5]);
    anmsel = SFC_sum.PFCchan.animal==(char(ianm));
    lbl = SFC_sum.PFCchan.T(anmsel);
    n = T.(ianm).nclust;
    n_lbl = arrayfun(@(i) sum(lbl==i),1:n);
    n_max = max(n_lbl); yl = [0,n_max]+0.5;
    chans_anm = SFC_sum.PFCchan.channels(anmsel);
    for i = 1:n
        % get PSTHs of selected channel into a matrix
        chans_clust = chans_anm(lbl==i);
        nch = numel(chans_clust);
        PSTHs = nan(nch,length(time));
        for ich = 1:nch
            chansel = chans_clust{ich};
            [~,idx] = ismember(chansel,multi_mod.files);
            PSTHs(ich,:) = mean(multi_mod.PSTH.dist{idx}(2:end,:),'omitnan');
        end
        % normalize PSTH to baseline
        PSTHs_bl = repmat(mean(PSTHs(:,t_bl),2,'omitnan'),1,length(time));
        PSTHs = (PSTHs-PSTHs_bl)./PSTHs_bl;
        % plot mean normalized PSTH
        m = mean(PSTHs,'omitnan');
        e = ste(PSTHs);
        fill([time,fliplr(time)],[m+e,fliplr(m-e)],cb(i),'FaceAlpha',0.3,'EdgeColor','none','HandleVisibility','off');
        plot(time,m,cb(i),'LineWidth',1);
    end
    ylim(ylx);
    ax = gca;
    ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
    xlim(xl);
    legend('boxoff');
    xlabel('Time from sample onset [s]');
    ylabel('Norm. PSTH');
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'renderer', 'painters'); % setting 'grid color reset' off
    print(fullfile(outfigf,sprintf('PSTH_by%dclust_%s_summary_norm',n,ianm)),'-dpng');
    print(fullfile(outfigf,sprintf('PSTH_by%dclust_%s_summary_norm',n,ianm)),'-dpdf','-r0','-bestfit');
% end