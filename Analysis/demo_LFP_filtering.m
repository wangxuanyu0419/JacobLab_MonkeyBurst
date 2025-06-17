function demo_LFP_filtering(chan,trl)
% demo for burst-prob. accumulation + single trial example
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs/demo_brst_prob';

session = chan(1:7);
channame = chan(9:12);
load(fullfile('/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror',session),'data_prep');

% Open figure
close all
fig = figure('Position',[0 0 500 500]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Raw LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(414); hold on; axis off;
ichan = cellfun(@(s) strcmp(s,channame),data_prep.label);
tlim = [-0.5,3.2]; time = data_prep.time{trl};
trng = time>=tlim(1) & time<=tlim(2);
lfp = data_prep.trial{trl}(ichan,trng);
plot(time(trng),lfp,'k');
% Add epoch line
xlim(tlim);
yl = ylim();
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);
%
ylabel('LFP','FontSize',10,'Visible','on')
text(0.03,-300,'Samp'); text(1.6,-300,'Dist');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Band-pass at HighGamma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(411); hold on; axis off;
HG = [60 90];
d_HG = ft_preproc_bandpassfilter(lfp,1e3,HG);
plot(time(trng),d_HG,'g');
xlim(tlim); yl = ylim();
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);
ylabel('60-90Hz','FontSize',10,'Visible','on')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Band-pass at LowGamma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(412); hold on; axis off;
LG = [35 60];
d_LG = ft_preproc_bandpassfilter(lfp,1e3,LG);
plot(time(trng),d_LG,'r');
xlim(tlim); yl = ylim();
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);
ylabel('35-60Hz','FontSize',10,'Visible','on')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Band-pass at Beta
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(413); hold on; axis off;
BT = [15 35];
d_BT = ft_preproc_bandpassfilter(lfp,1e3,BT);
plot(time(trng),d_BT,'b');
xlim(tlim); yl = ylim();
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);
ylabel('15-35Hz','FontSize',10,'Visible','on')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,sprintf('Demo_FiltLFP_%s_trl%d',chan,trl)),'-depsc')
print(fullfile(outfigf,sprintf('Demo_FiltLFP_%s_trl%d',chan,trl)),'-dpng')
end