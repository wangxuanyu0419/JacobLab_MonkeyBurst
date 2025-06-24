% This function calculates firing rate modulation by the burst:
%   - compare multi-unit FR within burst and outsid bursts
%   - compare modulation effect between different epochs (1+4), bands (highgamma/lowgamma/beta), task
%   conditions (4 x 5) and regions (PFC/VIP)

close all
clear; clc;

load('/mnt/storage/xuanyu/JacobLabMonkey/data/8.SpikeSorting/MultiChans/multi_mod.mat','multi_mod');
taskmod_files = multi_mod.files(multi_mod.taskmod); % 750 modulated channels for multiunit
nfiles = numel(taskmod_files);

epochs = {[-0.4 0.1],[0.1 0.6],[0.6 1.6],[1.6 2.1],[2.1 3.1]};
epoch_names = {'Fixa','Samp','Mem1','Dist','Mem2'};
bands = {[15 35],[35 60],[60 90]};
band_names = {'Beta','LowGamma','HighGamma'};
regions = {'PFC','VIP'};

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. get average FR for 5 (epoch) x 2 (In/Out) for each band (3) by each
% session, pooling over all conditions
%   - estimated per trial
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi';
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi/1.EpochxBand_newband';
indir = dir(fullfile(inf,'*.mat')); outdir = dir(fullfile(outf,'*.mat'));
infile = {indir.name}; outfile = {outdir.name};
filelist = setdiff(infile,outfile);

delete(gcp('nocreate'))
pools = parpool(32);
parfor ifile = 1:numel(filelist)
    try
        get_epochxband(filelist{ifile},epochs,bands);
    catch e
        fprintf('!!! Somthing wrong with %s \n   --- %s \n',taskmod_files{ifile},e.message);
    end
end

%%
indf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi/1.EpochxBand_newband';
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi';
% summarize the files
fr_mat_sum = struct();
fr_mat_sum.all = nan(nfiles,numel(epochs),numel(bands),2);
fr_mat_sum.cfg.epochs = epochs; fr_mat_sum.cfg.epoch_names = epoch_names;
fr_mat_sum.cfg.bands = bands; fr_mat_sum.cfg.band_names = band_names;
fr_mat_sum.cfg.regions = regions;
for ifile = 1:nfiles
    load(fullfile(indf,taskmod_files{ifile}),'fr_mat')
    fr_mat_sum.all(ifile,:,:,:) = fr_mat;
end
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),multi_mod.region(multi_mod.taskmod));
VIP_idx = cellfun(@(s) strcmp(s,'VIP'),multi_mod.region(multi_mod.taskmod));
fr_mat_sum.cfg.PFC_idx = PFC_idx;
fr_mat_sum.cfg.VIP_idx = VIP_idx;
% One nan in a channel indicates that no burst was recorded for that
% condition in the channel. substitute empty value with group mean. Only 29
% nans in 22500 values; 0 value indicates no spikes were recorded for the
% bursts in all trials of that condition, 68 cases observed.
PFCs = log10(fr_mat_sum.all(PFC_idx,:,:,:));
PFCs_reshape = reshape(PFCs,size(PFCs,1),size(PFCs,2)*size(PFCs,3)*size(PFCs,4));
[PFCs_clr,fr_mat_sum.cfg.PFC_clr_idx] = rmoutliers(PFCs_reshape,'median'); % 394/429 remains
fr_mat_sum.PFCs_clr = reshape(PFCs_clr,size(PFCs_clr,1),size(PFCs,2),size(PFCs,3),size(PFCs,4));

VIPs = log10(fr_mat_sum.all(VIP_idx,:,:,:));
VIPs_reshape = reshape(VIPs,size(VIPs,1),size(VIPs,2)*size(VIPs,3)*size(VIPs,4));
[VIPs_clr,fr_mat_sum.cfg.VIP_clr_idx] = rmoutliers(VIPs_reshape,'median'); % 309/321 remains
fr_mat_sum.VIPs_clr = reshape(VIPs_clr,size(VIPs_clr,1),size(VIPs,2),size(VIPs,3),size(VIPs,4));

fr_mat_sum.PFC = squeeze(nanmean(fr_mat_sum.PFCs_clr));
fr_mat_sum.PFC_se = squeeze(nanstd(fr_mat_sum.PFCs_clr)/sqrt(size(PFCs_clr,1)));
fr_mat_sum.VIP = squeeze(nanmean(fr_mat_sum.VIPs_clr));
fr_mat_sum.VIP_se = squeeze(nanstd(fr_mat_sum.VIPs_clr)/sqrt(size(VIPs_clr,1)));

save(fullfile(outf,'EpochxBand_newband_cntspk.mat'),'fr_mat_sum');

%% plot figure: bar plot with errorbar
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi';
load(fullfile(inf,'EpochxBand_newband_cntspk.mat'),'fr_mat_sum');
epoch_names = {'Fixa','Samp','Mem1','Dist','Mem2'};
band_names = {'Beta','LowGamma','HighGamma'};
close all
f = figure('Position',[100 100 1600 900]);
for i = 1:2 % region
    for j = 1:3 % band
        subplot(2,3,(i-1)*3+j)
        if i == 1 % PFC
            meanmat = squeeze(fr_mat_sum.PFC(:,j,:)); semat = squeeze(fr_mat_sum.PFC_se(:,j,:));
        else
            meanmat = squeeze(fr_mat_sum.VIP(:,j,:)); semat = squeeze(fr_mat_sum.VIP_se(:,j,:));
        end
        b = bar(meanmat,'LineWidth',1.5); hold on
        b(1).FaceColor = 'r'; b(2).FaceColor = 'b';
        x1 = b(1).XData+b(1).XOffset; x2 = b(2).XData+b(2).XOffset;
        er = errorbar([x1';x2'],meanmat(:),semat(:),'LineWidth',2);
        er.Color = 'k';
        er.LineStyle = 'none';
        
        ylim([0.4 1]);
        xticklabels(epoch_names);
        ylabel('average firing rate [log(Hz)]')
        legend({'inside','outside'})
        title(band_names{j})
    end
end
ax = axes(f,'Visible','off');
ax.YLabel.Visible = 'on';
ax.XLabel.Visible = 'on';
ylx = ylabel('VIP                            PFC','FontSize',30);
ylx.Position(1) = ylx.Position(1)-0.04;
tx = title('Average multiunit firing rate in-/outside of bursts','Visible','on','FontSize',25);
tx.Position(2) = tx.Position(2) + 0.025;
print(fullfile(inf,'EpochxBand_compare_InOut_newband_cntspk'),'-dpng')

%% Statistics: repeated measure anova for ratio difference (in-out)/out
%   - 1 between variable: region
%   - 2 within variable: band x epochs
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi';
load(fullfile(inf,'EpochxBand_newband_cntspk.mat'),'fr_mat_sum');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/8.SpikeSorting/MultiChans/multi_mod.mat','multi_mod');
fr_mat_sum.anova_result = struct();
fr_mat_sum.anova_result.alpha = 0.05;
data_sel = [];
region = [ones(sum(~fr_mat_sum.cfg.PFC_clr_idx),1); 2*ones(sum(~fr_mat_sum.cfg.VIP_clr_idx),1)];
files = multi_mod.files(multi_mod.taskmod); files = files([~fr_mat_sum.cfg.PFC_clr_idx;~fr_mat_sum.cfg.VIP_clr_idx])';
for j = 1:3
    data_sel = [data_sel [squeeze(fr_mat_sum.PFCs_clr(:,:,j,1)-fr_mat_sum.PFCs_clr(:,:,j,2));...
        squeeze(fr_mat_sum.VIPs_clr(:,:,j,1)-fr_mat_sum.VIPs_clr(:,:,j,2))]];
end
t = table(files,region,data_sel(:,1),data_sel(:,2),data_sel(:,3),data_sel(:,4),data_sel(:,5),data_sel(:,6),data_sel(:,7),data_sel(:,8),data_sel(:,9),data_sel(:,10),data_sel(:,11),data_sel(:,12),data_sel(:,13),data_sel(:,14),data_sel(:,15),...
    'VariableNames',{'IDs','region','d1','d2','d3','d4','d5','d6','d7','d8','d9','d10','d11','d12','d13','d14','d15'});
WithinStructure = table([ones(5,1);2*ones(5,1);3*ones(5,1)],[1:5 1:5 1:5]','VariableNames',{'band','epoch'});
WithinStructure.band = categorical(WithinStructure.band); WithinStructure.epoch = categorical(WithinStructure.epoch);

fr_mat_sum.anova_result.rm = fitrm(t,'d1-d15 ~ region','WithinDesign',WithinStructure);
fr_mat_sum.anova_result.spher = mauchly(fr_mat_sum.anova_result.rm);
fr_mat_sum.anova_result.spher_mit = fr_mat_sum.anova_result.spher.pValue > fr_mat_sum.anova_result.alpha;
fr_mat_sum.anova_result.tbl = ranova(fr_mat_sum.anova_result.rm,'WithinModel','band*epoch');
save(fullfile(inf,'EpochxBand_newband_cntspk.mat'),'fr_mat_sum');

%% Plot results corresponding to the statistics:
% The significant effects are:
%   - Region main effect;
%   - Band main effect;
%   - Region x Band Interaction;
%   - Region x Epoch Interaction;
%
%  Thus plot fr differences: Region (PFC/VIP) x Band (Beta/Gamma)
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi';
load(fullfile(inf,'EpochxBand_newband_cntspk.mat'),'fr_mat_sum');
fr_mat_sum.RegionxBand = struct;
fr_mat_sum.RegionxBand.regions = {'PFC','VIP'};
fr_mat_sum.RegionxBand.bands = {[15 35],[35 60],[60 90]};
fr_mat_sum.RegionxBand.band_names = {'Beta','LowGamma','HighGamma'};
fr_mat_sum.RegionxBand.fr_mean = nan(2,3);
fr_mat_sum.RegionxBand.fr_se = nan(2,3);

PFC_diff = squeeze(nanmean(fr_mat_sum.PFCs_clr(:,:,:,1)-fr_mat_sum.PFCs_clr(:,:,:,2),2));
VIP_diff = squeeze(nanmean(fr_mat_sum.VIPs_clr(:,:,:,1)-fr_mat_sum.VIPs_clr(:,:,:,2),2));
fr_mat_sum.RegionxBand.fr_mean(1,:) = nanmean(PFC_diff);
fr_mat_sum.RegionxBand.fr_mean(2,:) = nanmean(VIP_diff);
fr_mat_sum.RegionxBand.fr_se(1,:) = nanstd(PFC_diff,0,1)/sqrt(size(PFC_diff,1));
fr_mat_sum.RegionxBand.fr_se(2,:) = nanstd(VIP_diff,0,1)/sqrt(size(VIP_diff,1));

clist = distinguishable_colors(3);
close all
f = figure('Position',[100 100 500 400]);
b = bar(fr_mat_sum.RegionxBand.fr_mean,'LineWidth',1.5); hold on
x1 = b(1).XData+b(1).XOffset; x2 = b(2).XData+b(2).XOffset; x3 = b(3).XData+b(3).XOffset;
for i = 1:3; b(i).FaceColor = clist(i,:); end
er = errorbar([x1';x2';x3'],fr_mat_sum.RegionxBand.fr_mean(:),fr_mat_sum.RegionxBand.fr_se(:),'LineWidth',2,'HandleVisibility','off');
er.Color = 'k';
er.LineStyle = 'none';
xticklabels(fr_mat_sum.RegionxBand.regions);
ylabel('\DeltaFR_{In-Out} [log(Hz)]')
legend(band_names,'Location','northwest');

print(fullfile(inf,'RegionxBand_interaction_newband_fr_InOut'),'-dpng')

%% Evaluate gamma-burst modulation effect across task conditions / item numerosities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. get average log-difference FR between in/out, for 5 (epoch) x 4 (sample) x 5 (distractor)
%   - Only in gamma band
clear
load('/mnt/storage2/xuanyu/JacobLabMonkey/data/8.SpikeSorting/MultiChans/multi_mod.mat','multi_mod');
taskmod_files = multi_mod.files(multi_mod.taskmod); % 750 modulated channels for multiunit
nfiles = numel(taskmod_files);
epochs = {[-0.4 0.1],[0.1 0.6],[0.6 1.6],[1.6 2.1],[2.1 3.1]};
regions = {'PFC','VIP'};

delete(gcp('nocreate'))
pools = parpool(20);
parfor ifile = 1:nfiles
    get_epochxtask_gamma(taskmod_files{ifile},epochs);
end

%% Plot figures for item-specific gamma modulation at each site
%   1. PSTH
%   2. Gamma Burst Rate
%   3. Gamma Burst Amplitude
%   4. Gamma Burst Width
%   5. Gamma-burst-modulated FR across 5 epochs
% 1-5 separatedly for sample / distractor conditions (in two columns)
%   6. PEV
clear
load('/mnt/storage2/xuanyu/JacobLabMonkey/data/8.SpikeSorting/MultiChans/multi_mod.mat','multi_mod');
taskmod_files = multi_mod.files(multi_mod.taskmod); % 750 modulated channels for multiunit
nfiles = numel(taskmod_files);

delete(gcp('nocreate'))
pools = parpool(32);
parfor ifile = 1:nfiles
    try
        plot_epochxtask_chan(taskmod_files{ifile});
    catch
        fprintf('!!! Somthing wrong with %s\n',taskmod_files{ifile});
    end
end

%% Average FR_in/out across whole trial time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. get average FR for 2 conditions (In/Out) of each band (3) by each
% session, pooling over all conditions
%   - estimated per trial
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi';
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi/4.Band_AllTrl';
indir = dir(fullfile(inf,'*.mat')); outdir = dir(fullfile(outf,'*.mat'));
infile = {indir.name}; outfile = {outdir.name};
filelist = setdiff(infile,outfile);

delete(gcp('nocreate'))
pools = parpool(20);
parfor ifile = 1:numel(filelist)
    try
        get_band_alltrl(filelist{ifile},bands);
    catch e
        fprintf('!!! Somthing wrong with %s \n   --- %s \n',taskmod_files{ifile},e.message);
    end
end

%% Summary FR_in/out alltrl
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi/4.Band_AllTrl';
dirf = dir(fullfile(inf,'*.mat')); files = {dirf.name}; nfile = numel(files);
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi';

% summarize the files
fr_mat_sum = struct();
fr_mat_sum.all = nan(nfile,numel(bands),2);
fr_mat_sum.cfg.epochs = epochs; fr_mat_sum.cfg.epoch_names = epoch_names;
fr_mat_sum.cfg.bands = bands; fr_mat_sum.cfg.band_names = band_names;
fr_mat_sum.cfg.regions = regions;

prog = 0.0;
fprintf('>>> Loading data: %3.0f%%\n',prog)
for ifile = 1:nfiles
    load(fullfile(inf,taskmod_files{ifile}),'fr_mat')
    fr_mat_sum.all(ifile,:,:,:) = fr_mat;
    prog = ifile/nfiles*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),multi_mod.region(multi_mod.taskmod));
VIP_idx = cellfun(@(s) strcmp(s,'VIP'),multi_mod.region(multi_mod.taskmod));
fr_mat_sum.cfg.PFC_idx = PFC_idx;
fr_mat_sum.cfg.VIP_idx = VIP_idx;
PFCs = log10(fr_mat_sum.all(PFC_idx,:,:,:));
PFCs_reshape = reshape(PFCs,size(PFCs,1),size(PFCs,2)*size(PFCs,3));
[PFCs_clr,fr_mat_sum.cfg.PFC_clr_idx] = rmoutliers(PFCs_reshape,'median');
fr_mat_sum.PFCs_clr = reshape(PFCs_clr,size(PFCs_clr,1),size(PFCs,2),size(PFCs,3));

VIPs = log10(fr_mat_sum.all(VIP_idx,:,:,:));
VIPs_reshape = reshape(VIPs,size(VIPs,1),size(VIPs,2)*size(VIPs,3));
[VIPs_clr,fr_mat_sum.cfg.VIP_clr_idx] = rmoutliers(VIPs_reshape,'median');
fr_mat_sum.VIPs_clr = reshape(VIPs_clr,size(VIPs_clr,1),size(VIPs,2),size(VIPs,3));

fr_mat_sum.PFC = squeeze(nanmean(fr_mat_sum.PFCs_clr));
fr_mat_sum.PFC_se = squeeze(nanstd(fr_mat_sum.PFCs_clr)/sqrt(size(PFCs_clr,1)));
fr_mat_sum.VIP = squeeze(nanmean(fr_mat_sum.VIPs_clr));
fr_mat_sum.VIP_se = squeeze(nanstd(fr_mat_sum.VIPs_clr)/sqrt(size(VIPs_clr,1)));

save(fullfile(outf,'EpochxBand_newband_cntspk_alltrl.mat'),'fr_mat_sum');
