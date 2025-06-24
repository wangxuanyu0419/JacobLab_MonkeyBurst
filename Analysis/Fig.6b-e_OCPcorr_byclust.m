% plot OCP correlate performance results with cluster separation
%% Plot for performance correlation
% bar plot
clear; close all; clc;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/13.PerfOCP/OCPcorrect_error';
load(fullfile(inf,'OCP_corr'),'OCP_corr');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
% load the new clusters
load('/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_VIP2PFC_byepoch_byloc/SFC_sum','SFC_sum');
PFCchan = SFC_sum.PFCchan;
PFCchan.T_new = 4-PFCchan.T; % switch cluster label 1 and 3;
%%
close all
fig = figure('Position',[10 10 400 800]); hold on;
cx = ["b","r"];
ste = @(x) std(x)/sqrt(length(x));
for ianm = ["R","W"]
    [~,ia] = ismember(ianm,["R","W"]);
    T = PFCchan.T_new(cellfun(@(x) x(1)==ianm,PFCchan.channels));
    for ic = 1:3
        avg = nan(2,1); err = nan(2,1);
        subplot(3,2,ic*2+ia-2); hold on;
        for iband = ["HighGamma","Beta"]
            [~,ib] = ismember(iband,["HighGamma","Beta"]);
            data.(iband) = OCP_corr.(ianm).(iband)(T==ic);
            avg = median(data.(iband));
            err = ste(data.(iband));
            bar(ib,avg,'FaceColor',cx{ib},'BarWidth',0.8);
            errorbar(ib,avg,err,'Color','k','CapSize',3);
        end
        [p,h] = ranksum(data.HighGamma,data.Beta);
        xticks([1,2]); xticklabels(["HG","BT"]);
        ylim([-1,1]);
        title(sprintf('%s-Clust#%d n=%d\np=%.03f',ianm,ic,sum(T==ic),p));
        ylabel('\DeltaOCP [\it{t}\rm]');
        set(gca,'TickDir','out');
        set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    end
end
set(gcf,'Renderer','painters');
print(fullfile(outf,'OCPcorrPF_byclust'),'-dpng');
print(fullfile(outf,'OCPcorrPF_byclust'),'-dpdf','-r0')
%% Plot for RT correlation
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/13.PerfOCP/OCPcorrRT';
load(fullfile(inf,'OCPcorrRT_all'),'OCPcorrRT_all');
close all
fig = figure('Position',[10 10 400 800]); hold on;
for ianm = ["R","W"]
    [~,ia] = ismember(ianm,["R","W"]);
    idx_anm = cellfun(@(x) x(1)==ianm,PFCchan.channels);
    T = PFCchan.T_new(idx_anm);
    for ic = 1:3
        avg = nan(2,1); err = nan(2,1);
        subplot(3,2,ic*2+ia-2); hold on;
        for iband = ["HighGamma","Beta"]
            [~,ib] = ismember(iband,["HighGamma","Beta"]);
            corrRT = OCPcorrRT_all.PFC.(iband)(idx_anm);
            data.(iband) = corrRT(T==ic);
            avg = median(data.(iband));
            err = ste(data.(iband));
            bar(ib,avg,'FaceColor',cx{ib},'BarWidth',0.8);
            errorbar(ib,avg,err,'Color','k','CapSize',3);
        end
        [p,h] = ranksum(data.HighGamma,data.Beta);
        xticks([1,2]); xticklabels(["HG","BT"]);
        ylim([-0.15,0.15])
        title(sprintf('%s-Clust#%d n=%d\np=%.03f',ianm,ic,sum(T==ic),p));
        ylabel('Corr. Coef.');
        set(gca,'TickDir','out');
        set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    end
end
print(fullfile(outf,'OCPcorrRT_byclust'),'-dpng');
print(fullfile(outf,'OCPcorrRT_byclust'),'-dpdf','-r0')
%% Plot for VIP, separated by animals
close all
fig = figure('Position',[10 10 400 500]); hold on;
VIP_sel = cellfun(@(r) strcmp(r,"VIP"),OCP_corr.region);
for ianm = ["R","W"]
    [~,ia] = ismember(ianm,["R","W"]);
    chan_sel = cellfun(@(f,r) strcmp(f(1),ianm) & strcmp(r,"VIP"), OCP_corr.files,OCP_corr.region);
    % Plot RT
    subplot(2,2,ia); hold on;
    for iband = ["HighGamma","Beta"]
            [~,ib] = ismember(iband,["HighGamma","Beta"]);
            data.(iband) = OCPcorrRT_all.(iband)(chan_sel,1);
            avg = median(data.(iband));
            err = ste(data.(iband));
            bar(ib,avg,'FaceColor',cx{ib},'BarWidth',0.8);
            errorbar(ib,avg,err,'Color','k','CapSize',3);
    end
    [p,h] = ranksum(data.HighGamma,data.Beta);
    xticks([1,2]); xticklabels(["HG","BT"]);
    ylim([-0.15,0.15])
    title(sprintf('%s-VIP n=%d\np=%.03f',ianm,sum(chan_sel),p));
    ylabel('Corr. Coef.');
    set(gca,'TickDir','out');
    % Plot Performance
    subplot(2,2,ia+2); hold on;
    for iband = ["HighGamma","Beta"]
            [~,ib] = ismember(iband,["HighGamma","Beta"]);
            data.(iband) = OCP_corr.tavg.VIP.(iband)(cellfun(@(f) strcmp(f(1),ianm), OCP_corr.files(VIP_sel)));
            avg = median(data.(iband));
            err = ste(data.(iband));
            bar(ib,avg,'FaceColor',cx{ib},'BarWidth',0.8);
            errorbar(ib,avg,err,'Color','k','CapSize',3);
    end
    [p,h] = ranksum(data.HighGamma,data.Beta);
    xticks([1,2]); xticklabels(["HG","BT"]);
    ylim([-1,1])
    title(sprintf('%s-VIP n=%d\np=%.03f',ianm,sum(chan_sel),p));
    ylabel('Corr. Coef.');
    set(gca,'TickDir','out');
end
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
print(fullfile(outf,'OCPcorr_VIP_byanm'),'-dpng');
print(fullfile(outf,'OCPcorr_VIP_byanm'),'-dpdf','-r0')
%% Perform test to zero for each condition
st = struct();
h = nan(8,1); p = h; stats = cell(8,1);
animal = [repmat("R",4,1);repmat("W",4,1)];
cluster = [1,2,3,"VIP",1,2,3,"VIP"]';
VIP_sel = cellfun(@(r) strcmp(r,"VIP"),OCP_corr.region);
for iband = ["HighGamma","Beta"]
    [~,ib] = ismember(iband,["HighGamma","Beta"]);
    st.(iband) = struct();
    for icond = ["perf","RT"]
        st.(iband).(icond) = table(animal,cluster,h,p,stats);
        for ianm = ["R","W"]
            [~,ia] = ismember(ianm,["R","W"]);
            idx_anm = cellfun(@(x) x(1)==ianm,PFCchan.channels);
            T = PFCchan.T_new(cellfun(@(x) x(1)==ianm,PFCchan.channels));
            % PFC clusters
            for ic = 1:3
                switch icond
                    case "perf"
                        data = OCP_corr.(ianm).(iband)(T==ic);
                    case "RT"
                        corrRT = OCPcorrRT_all.PFC.(iband)(idx_anm);
                        data = corrRT(T==ic);
                end
                [st.(iband).(icond).h(ia*4-4+ic), st.(iband).(icond).p(ia*4-4+ic),~,st.(iband).(icond).stats{ia*4-4+ic}] = ttest(data);
            end
            % VIP
            switch icond
                case "perf"
                    data = OCP_corr.tavg.VIP.(iband)(cellfun(@(f) strcmp(f(1),ianm), OCP_corr.files(VIP_sel)));
                case "RT"
                    chan_sel = cellfun(@(f,r) strcmp(f(1),ianm) & strcmp(r,"VIP"), OCP_corr.files,OCP_corr.region);
                    data = OCPcorrRT_all.(iband)(chan_sel,1);
            end
            [st.(iband).(icond).h(ia*4), st.(iband).(icond).p(ia*4),~,st.(iband).(icond).stats{ia*4}] = ttest(data);
        end
    end
end
save('/mnt/storage/xuanyu/JacobLabMonkey/data/13.PerfOCP/OCP_by_clust_stat.mat','st');