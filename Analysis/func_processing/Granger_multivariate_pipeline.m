% perform multivariate granger for inter-cluster causality.
% first do it for inter-regional (PFC-VIP):
clear; close all; clc;
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/24.ERP/0.TrialScreening_inclerror';
dirf = dir(fullfile(inf,'*.mat')); sesses = {dirf.name};
load('/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/SFC_sum_interreg.mat','SFC_sum_V2P');
PFCchan = SFC_sum_V2P.PFCchan(:,[1,5]);
% merge cluster 1 and 2 for monkey W
W = cellfun(@(s) s(1)=='W',PFCchan.channels);
for i = 2:4
    PFCchan.T(W&PFCchan.T==i) = i-1;
end
% % example session
% sess = 'W120919.';
% T = PFCchan.T(cellfun(@(s) strcmp(s(1:7),sess(1:7)),PFCchan.channels));
% get_sess_interreg_condgc(sess,T);
delete(gcp("nocreate")); parpool(32);
parfor isess = 1:numel(sesses)
    T = PFCchan.T(cellfun(@(s) strcmp(s(1:7),sesses{isess}(1:7)),PFCchan.channels));
    get_sess_interreg_condgc(sesses{isess},T);
    fprintf('>>> Completed %s\n',sesses{isess});
end
%% summary
grgf = '/mnt/storage/xuanyu/MONKEY/Non-ion/26.connectivity/sess_grg_cond';
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/26.connectivity/trialwise_grg_cond';
grg_sum = struct();
grg_sum.files = sesses;
grg_sum.R = cell(4);
grg_sum.W = cell(4);
ic = 1;
for i = 1:3
    s = sprintf('PFC%d',i);
    grg_sum.labels{ic} = s;
    ic = ic+1;
end
grg_sum.labels{ic} = 'VIP';
prog = 0.0; fprintf('>>> Loading data: %3.0f%%\n',prog);
for isess = 1:numel(sesses)
    load(fullfile(grgf,sesses{isess}),'grg');
    for icmb = 1:size(grg.labelcmb,1)
        [~,ix] = ismember(grg.labelcmb(icmb,1),grg_sum.labels);
        [~,iy] = ismember(grg.labelcmb(icmb,2),grg_sum.labels);
        grg_sum.(sesses{isess}(1)){ix,iy}(end+1,:) = grg.grangerspctrm(icmb,:);
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,'grg_sum'),'grg_sum');
%% Plot results: inter-regional
freq = grg.freq;
close all; fig = figure('Position',[0 0 250 500]);
c = 'rbg'; fx = 6; fsel = freq>=(50-fx) & freq<=(50+fx);
for ianm = ["R","W"]
    clf(fig,'reset');
    switch ianm
        case 'R'; yl = [0 0.3];
        case 'W'; yl = [0 0.5];
    end
    for icond = ["PFC2VIP","VIP2PFC"]
        switch icond
            case 'PFC2VIP'
                subplot(2,1,1); hold on;
                data = grg_sum.(ianm)(1:3,4);
            case 'VIP2PFC'
                subplot(2,1,2); hold on;
                data = grg_sum.(ianm)(4,1:3);
        end
        for x = 1:3
            d = mean(data{x},'omitnan');
            d(fsel) = nan;
            i = 1:numel(d);
            d(isnan(d)) = interp1(i(~isnan(d)), d(~isnan(d)), i(isnan(d)), 'linear');
            m = smoothdata(d,'gaussian',5);
%             plot(freq,m,c(x),'DisplayName',sprintf('Clust#%d',x));
            plot(log2(freq),m,c(x),'LineWidth',1,'DisplayName',sprintf('Clust#%d',x));
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
    print(fullfile(outf,sprintf('Inter_CondGC_byclust_%s_stacked',ianm)),'-dpdf','-r0','-bestfit');
    print(fullfile(outf,sprintf('Inter_CondGC_byclust_%s_stacked',ianm)),'-dpng');
end
%% Plot results: band, bars, DI
P2V = grg_sum.R(1:3,4);
V2P = grg_sum.R(4,1:3);
f_low = [2,8]; flsel = freq>=f_low(1)&freq<f_low(2);
f_high = [16,32]; fhsel = freq>=f_high(1)&freq<f_high(2);
% compute a differential index
dl = cellfun(@(d1,d2) mean(d1(:,flsel)-d2(:,flsel),2)./mean(d1(:,flsel)+d2(:,flsel),2),P2V(:),V2P(:),'UniformOutput',false);
dh = cellfun(@(d1,d2) mean(d1(:,fhsel)-d2(:,fhsel),2)./mean(d1(:,fhsel)+d2(:,fhsel),2),P2V(:),V2P(:),'UniformOutput',false);
m = [cellfun(@mean,dl),cellfun(@mean,dh)];
e = [cellfun(@ste,dl),cellfun(@ste,dh)];
close all; fig = figure('Position',[0 0 200 120]); hold on;
x = [3,2,1,7,6,5];
bar(x,m(:)); errorbar(x,m(:),e(:),'k','LineStyle','none','LineWidth',1);
ylim([-0.8,0.4]); xticks([]); set(gca,'TickDir','out');
yticks([-0.5,0]);
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf,'Renderer','painters');
print(fullfile(outf,'Inter_CondGC_byclust_R_bar_DI'),'-dpdf','-r0');
print(fullfile(outf,'Inter_CondGC_byclust_R_bar_DI'),'-dpng');
%% add statistics
pl = cellfun(@signrank,dl); ph = cellfun(@signrank,dh);
%% Plot results: band, bars, absolute
for ianm = ["R","W"]
    P2V = grg_sum.(ianm)(1:3,4);
    V2P = grg_sum.(ianm)(4,1:3);
    d1 = cellfun(@(d) mean(d(:,flsel),2),P2V,'UniformOutput',false);
    m1 = cellfun(@mean,d1); e1 = cellfun(@ste,d1);
    d2 = cellfun(@(d) mean(d(:,fhsel),2),V2P,'UniformOutput',false);
    m2 = cellfun(@mean,d2); e2 = cellfun(@ste,d2);
    m = [m1(:),m2(:)]'; e = [e1(:),e2(:)]';
    xe = [-1 0 1]*0.25;
    x = [ones(1,3)+xe; 2.*ones(1,3)+xe];
    name = {'P2V 2-8Hz','V2P 16-32Hz'};
    close all; fig = figure('Position',[0 0 300 150]); hold on;
    b = bar(m); xticks(1:2); xticklabels(name);
    errorbar(x,m,e,'k','LineStyle','none','LineWidth',0.5);
    set(gca,'TickDir','out');
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    print(fullfile(outf,sprintf('Inter_CondGC_byclust_%s_bar',ianm)),'-dpng');
    print(fullfile(outf,sprintf('Inter_CondGC_byclust_%s_bar',ianm)),'-dpdf','-r0');
end
%% functions
function get_sess_interreg_condgc(sess,T)
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/24.ERP/0.TrialScreening_inclerror';
load(fullfile(inf,sess),'data_prep');
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/26.connectivity/sess_grg_cond';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add notch filter
cfg            = [];
cfg.bsfilter   = 'yes';
cfg.bsfreq     = [45,55;90,110;135,165];
cfg.bsfiltord  = 4;
evalc('data = ft_preprocessing(cfg,data_prep);');
% select data by trial time
cfg = [];
cfg.latency = [-0.5,3.2];
evalc('data = ft_selectdata(cfg,data);');
% quick fourier
cfg               = [];
cfg.method        = 'mtmfft';
cfg.output        = 'fourier';
cfg.tapsmofrq     = 2;
cfg.foilim        = [0 100];
cfg.keeptrials    = 'yes';
cfg.channel       = 'all';
cfg.pad           = 'nextpow2';
cfg.trials        = data.trialinfo.errorcode==0;
evalc('freq = ft_freqanalysis(cfg, data);');
% granger
cfg                     = [];
cfg.method              = 'granger';
cfg.channelcmb          = freq.label;
cfg.granger.conditional = 'yes';
cfg.granger.sfmethod    = 'multivariate';
cfg.granger.block       = struct();
ic = 1;
for i = 1:3
    if sum(T==i)==0; continue; end
    cfg.granger.block(ic).name = sprintf('PFC%d',i);
    cfg.granger.block(ic).label = freq.label(T==i);
    ic = ic+1;
end
cfg.granger.block(ic).name   = 'VIP';
cfg.granger.block(ic).label  = freq.label(length(T)+1:end);
evalc('grg = ft_connectivityanalysis(cfg, freq);');
save(fullfile(outf,sess),'grg');
end
