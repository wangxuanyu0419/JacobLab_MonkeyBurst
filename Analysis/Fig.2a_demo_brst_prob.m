function demo_brst_prob(chan,trl)
% demo for burst-prob. accumulation + single trial example
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs/demo_brst_prob';

session = chan(1:7);
channame = chan(9:12);

% Open figure
close all
fig = figure('Position',[0 0 1000 1000]);
ax = axes(fig,'Position',[0.07, 0.82, 0.35, 0.12]); plot_raw(ax,session,channame,trl);
ax = axes(fig,'Position',[0.07, 0.43, 0.35, 0.3]); plot_norm(ax,chan,trl);
ax = axes(fig,'Position',[0.07, 0.05, 0.35, 0.3]); plot_fit(ax,chan,trl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add frequency band specification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tlim = [-0.5,3.2]; flim = [2,100];
arrayfun(@(y) plot(tlim,[y y],'--r','LineWidth',1.5),[15 35 60 90]);
cband = {'b','r','g'}; yrng = {[15 35], [35 60], [60 90]};

ax = axes(fig,'Position',[0.42, 0.05, 0.02, 0.3]); axis off; hold on;
arrayfun(@(i) fill([0 1 1 0],[yrng{i}(1) yrng{i}(1) yrng{i}(2) yrng{i}(2)],cband{i}),1:3);
ylim(flim);
% Add description
text(0.5,62,'HighGamma','Rotation',90);
text(0.5,35,'LowGamma','Rotation',90);
text(0.5,19,'Beta','Rotation',90);

%% Demo upper-right
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo1: trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
brsts = [1,0.12,0.08,0.5,0.2,0.05; 1.5,0.4,0.2,0.2,0.05,0; 2,0.6,0.02,0.8,0.2,-0.01];
xx = 0:0.01:1; yy = xx;
for i = 1:3
    ax = axes(fig,'Position',[0.38+0.14*i, 0.76, 0.135, 0.14]); axis off; hold on;
    [X,Y] = ndgrid(xx,yy); R = cat(3,X,Y);
    z = gauss2d(brsts(i,:),R);
    imagesc(xx,yy,z'); caxis([0 2])
    title(sprintf('Burst %d',i));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo2: burst-prob.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:3
    ax = axes(fig,'Position',[0.38+0.14*i, 0.67, 0.135, 0.05]); axis off; hold on;
    br = expand_burst(brsts(i,2),brsts(i,3),length(xx),1/2);
    brt(i,:) = histcounts(br,[xx-diff(xx(1:2))/2,xx(end)+diff(xx(1:2))/2]);
    plot(xx,brt(i,:),'r','LineWidth',2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo3: accumulated burst prob.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax = axes(fig,'Position',[0.58, 0.48, 0.31, 0.1]); hold on;
brt_avg = mean(brt);
plot(xx,brt_avg,'r','LineWidth',2);
xticks([]); xlabel('Time','FontSize',15);
ylim([0 1]); yticks([0 1]); ylabel(sprintf('Accum. \n Burst Prob.'),'FontSize',13);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Accum. Burst Pro. for example channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y0 = 0.045; yr = 0.3;
load(fullfile('/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc',chan),'data_burst')
brst_sel = data_burst.trialinfo.bursts{trl};
time = data_burst.time; freq = data_burst.freq;
for i = 1:3
    yl = yrng{i};
    ax = axes(fig,'Position',[0.52,y0+yr*yl(1)/diff(flim),0.42,yr*diff(yl)/diff(flim)-0.01]); hold on;
    brsts = brst_sel(brst_sel.f>=yrng{i}(1) & brst_sel.f<=yrng{i}(2),:);
    br = arrayfun(@(i) expand_burst(brsts.t(i),brsts.t_sd(i),1000,1/2),1:height(brsts),'uni',0);
    br = vertcat(br{:});
    brt_eg(i,:) = histcounts(br,[time-diff(time(1:2))/2,time(end)+diff(time(1:2))/2]);
    plot(time,brt_eg(i,:),cband{i},'LineWidth',2);
    
    yl = ylim();
    arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);
    if i~=1
        xticks([]); 
    else
        xlabel('Time to Sample Onset [s]');
    end
    xlim(tlim);
end
ax = axes(fig,'Position',[0.52,y0+yr*yrng{1}(1)/diff(flim),0.42,yr*(90-15)/diff(flim)-0.01],'Visible','off');
ylabel('Burst Prob.','FontSize',15,'Visible','on');

%% Export figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export the figure in eps format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
print(fullfile(outfigf,sprintf('Demo_BR_%s_trl%d',chan,trl)),'-dpdf','-r0','-bestfit')
print(fullfile(outfigf,sprintf('Demo_BR_%s_trl%d',chan,trl)),'-dpng')
% close all;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw-LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_raw(ax,session,channame,trl)
axes(ax); hold on; axis off;

load(fullfile('/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror',session),'data_prep');
ichan = cellfun(@(s) strcmp(s,channame),data_prep.label);
tlim = [-0.5,3.2]; time = data_prep.time{trl};
trng = time>=tlim(1) & time<=tlim(2);
lfp = data_prep.trial{trl}(ichan,trng);

plot(time(trng),lfp,'m');
% Add epoch line
xlim(tlim);
yl = ylim()*1.5;
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);

title('Local-field Potential','FontSize',12)
text(0.03,-300,'Samp'); text(1.6,-300,'Dist');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot normalized spectrogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_norm(ax,chan,trl)
axes(ax); hold on;
ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
tlim_spec = [-0.51,3.21]; flim_spec = [1,100];

load(fullfile('/mnt/storage/xuanyu/MONKEY/Non-ion/2.Normalized_inclerror',chan),'data_norm');
time = data_norm.time; freq = data_norm.freq;
z = squeeze(data_norm.powspctrm_norm(trl,:,:));
% z(z<2) = 0; % filter at thr = 2;
imagesc(time,freq,z);
xlim(tlim_spec); ylim(flim_spec); clim([0 4]);
colorbar; colormap('jet');
% Add epoch line
yl = ylim();
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);

xticks([0 0.5 1.5 2 3]);
ylabel('Frequency [Hz]');
title('Norm. Spectrogram (z > 2)','FontSize',12)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fitted bursts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_fit(ax,chan,trl)
axes(ax); hold on;
ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
tlim_spec = [-0.51,3.21]; flim_spec = [1,100];

load(fullfile('/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc',chan),'data_burst')
brst_sel = data_burst.trialinfo.bursts{trl};
brst_sel.theta = brst_sel.theta/(2*pi);
brst_crit = table2array(brst_sel(:,2:7));
% create grid:
time = data_burst.time; freq = data_burst.freq;
[T,F] = ndgrid(time,freq); R = cat(3,T,F);
z = arrayfun(@(i) gauss2d(brst_crit(i,:),R), 1:size(brst_crit,1),'uni',0);
z_mat = cat(3,z{:}); z_sum = sum(z_mat,3);

imagesc(time,freq,z_sum');
xlim(tlim_spec); ylim(flim_spec); caxis([0 5]);
% Add epoch line
yl = ylim();
arrayfun(@(x) plot([x x],yl,'--k','LineWidth',1.5),[0 0.5 1.5 2 3]);

xlabel('Time to Sample Onset [s]');
xticks([0 0.5 1.5 2 3]);
ylabel('Frequency [Hz]');
title('Fitted 2D Gaussians','FontSize',12)
end
