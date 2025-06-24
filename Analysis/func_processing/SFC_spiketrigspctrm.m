% Compute MUA spike-triggered spectrogram for all valid MUA channels, store
% on disk. All trials (correct + error) taken. LFP linear interpolation
% around spikes NOT performed

clc
clear
close all

% ft_preprocessing and ft_definetrial already done, see 0.TrialScreening
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};

% % test session
% get_spktrgspctrm(sesses{1}(1:7));

delete(gcp('nocreate'));
parpool(32);
parfor isess = 1:numel(sesses)
    sess = sesses{isess}(1:7);
    get_spktrgspctrm(sess);
%     get_spktrgspctrm_unint(sess); % non-interpolated SFC
end

%% Filtering out spikes in/out bursts, un-interpolated (spikes are the same as interpolated)
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint';
dirf = dir(fullfile(inf,'*.mat')); filesin = {dirf.name};
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst'; mkdir(outf);
outdirf = dir(fullfile(outf,'*.mat')); filesout = {outdirf.name};
files = setdiff(filesin,filesout);

% % test chan
% sort_spk(files{1});

delete(gcp('nocreate'));
parpool(32);
parfor ifile = 1:numel(files)
    sort_spk(inf,outf,files{ifile});
    fprintf('>>> Completed %s\n',files{ifile});
end

%% Complete pipeline non-interpolated
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint';
dirf = dir(fullfile(inf,'*.mat')); filesin = {dirf.name};
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst_unint'; mkdir(outf);
outdirf = dir(fullfile(outf,'*.mat')); filesout = {outdirf.name};
files = setdiff(filesin,filesout);

delete(gcp('nocreate'));
parpool(32);
parfor ifile = 1:numel(files)
    sort_spk(inf,outf,files{ifile});
    fprintf('>>> Completed %s\n',files{ifile});
end

% summary
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst_unint';
dirf = dir(fullfile(inf,'*.mat')); files = {dirf.name};
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC';
SFC_brst_all = struct();
SFC_brst_all.files = files;
SFC_brst_all.channel = [];
SFC_brst_all.valid = multi_mod.taskmod;

prog = 0.0;
fprintf('>>> Loading data: %3.0f%%\n',prog)
for i = 1:numel(files)
    load(fullfile(inf,files{i}),'SFC_brst');
    SFC_brst_all.channel = vertcat(SFC_brst_all.channel,{SFC_brst.channel});
    if i==1
        SFC_brst_all.time = SFC_brst.time; SFC_brst_all.step = SFC_brst.step;
        SFC_brst_all.win = SFC_brst.win; SFC_brst_all.tds = SFC_brst.tds;
        SFC_brst_all.freq = SFC_brst.freq;
        for iband = ["Beta","LowGamma","HighGamma"]
            for icond = ["in","out"]
                SFC_brst_all.(iband).(icond).SFC = nan(numel(files),length(SFC_brst_all.tds),length(SFC_brst_all.freq));
                SFC_brst_all.(iband).(icond).nspk = nan(numel(files),length(SFC_brst_all.tds));
            end
        end
    end
    for iband = ["Beta","LowGamma","HighGamma"]
        for icond = ["in","out"]
            SFC_brst_all.(iband).(icond).SFC(i,:,:) = SFC_brst.(iband).(icond).SFC;
            SFC_brst_all.(iband).(icond).nspk(i,:) = SFC_brst.(iband).(icond).nspike;
        end
    end
    prog = i/numel(files)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,'SFC_brst_all_unint'),'SFC_brst_all');

% Plot results + diff
regions = ["PFC","VIP"];
SFC_brst_all.region = cellfun(@(s) regions((str2double(s(11:12))>8)+1), SFC_brst_all.channel,'uni',0);
flim = round(SFC_brst_all.freq([1,end])); tlim = [-0.5,3.2];
close all
fig = figure('Position',[0 0 1000 800]);
c.Beta = 'b'; c.LowGamma = 'r'; c.HighGamma = 'g';

for ireg = regions
    clf(fig,'reset');
    regsel = cellfun(@(s) strcmp(s,ireg),SFC_brst_all.region);
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; y0 = 0.06;
            case 'LowGamma'; y0 = 0.38;
            case 'HighGamma'; y0 = 0.7;
        end
        data.in = SFC_brst_all.(iband).in.SFC(regsel&SFC_brst_all.valid,:,:); % note there are Inf values in data?
        data.in(abs(data.in)==Inf)=nan;
        data.out = SFC_brst_all.(iband).out.SFC(regsel&SFC_brst_all.valid,:,:);
        data.out(abs(data.out)==Inf)=nan;
        for icond = ["in","out","diff"]
            switch icond
                case 'in'; x0 = 0.06; cl = [0 0.015]; z = squeeze(nanmean(data.in));
                case 'out'; x0 = 0.38; cl = [0 0.015]; z = squeeze(nanmean(data.out));
                case 'diff'; x0 = 0.7; cl = [-0.01,0.01];
                    din = permute(data.in,[3 2 1]);
                    dout = permute(data.out,[3 2 1]);
                    [clusts, p, t, ~] = permutest(din,dout,1,[],[],1);
                    clustsel = clusts(p<0.05); sig = false(size(din,1),size(din,2));
                    for i = 1:numel(clustsel); sig(clustsel{i})=true; end
                    z = squeeze(nanmean(din-dout,3))'; z(~sig') = 0;
            end
            ax = axes(fig,'Position',[x0, y0, 0.25, 0.24]); hold on;
            
            imagesc(SFC_brst_all.tds,SFC_brst_all.freq,z');
            arrayfun(@(x) plot([x x],flim,'--k','LineWidth',2), [0,0.5,1.5,2,3]);
            caxis(cl);
            set(gca,'YDir','normal');
            cb = colorbar;
            if strcmp(icond,'diff')
                colormap(gca,redblue); cb.Label.String = 'PPC Diff.';
            else
                colormap(gca,jet); cb.Label.String = 'PPC';
            end
            xlim(ax,tlim); ylim(flim);
            ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
            xlabel('Time from sample onset [s]')
            if strcmp(icond,'in'); ylabel('Frequency [Hz]'); end
            if strcmp(iband,'HighGamma'); title(icond,'FontSize',15); end
        end
        axes(fig,'Position',[0.05,y0,0.9,0.28],'Visible','off');
        ylabel(iband,'Color',c.(iband),'FontSize',20);
    end
    for icond = ["in","out","diff"]
        switch icond
            case 'in'; x0 = 0.7;
            case 'out'; x0 = 0.38;
            case 'diff'; x0 = 0.06;
        end
        axes(fig,'Position',[x0,0.06,0.28,0.89],'Visible','off');
        title(icond,'FontSize',20);
    end
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; y0 = 0.06;
            case 'LowGamma'; y0 = 0.38;
            case 'HighGamma'; y0 = 0.7;
        end
        axes(fig,'Position',[0.06,y0,0.89,0.24],'Visible','off');
        ylabel(iband,'FontSize',20,'Visible','on');
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outf,sprintf('SFC_brst_clust_%s_unint',ireg)),'-depsc');
    print(fullfile(outf,sprintf('SFC_brst_clust_%s_unint',ireg)),'-dpng');
end

% Plot result + clustcorr
regions = ["PFC","VIP"];
SFC_brst_all.region = cellfun(@(s) regions((str2double(s(11:12))>8)+1), SFC_brst_all.channel,'uni',0);
flim = round(SFC_brst_all.freq([1,end])); tlim = [-0.5,3.2];
close all
fig = figure('Position',[0 0 1000 800]);
c.Beta = 'b'; c.LowGamma = 'r'; c.HighGamma = 'g';

for ireg = regions
    clf(fig,'reset');
    regsel = cellfun(@(s) strcmp(s,ireg),SFC_brst_all.region);
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; y0 = 0.06;
            case 'LowGamma'; y0 = 0.38;
            case 'HighGamma'; y0 = 0.7;
        end
        data.in = SFC_brst_all.(iband).in.SFC(regsel&SFC_brst_all.valid,:,:); % note there are Inf values in data?
        data.in(abs(data.in)==Inf)=nan;
        data.out = SFC_brst_all.(iband).out.SFC(regsel&SFC_brst_all.valid,:,:);
        data.out(abs(data.out)==Inf)=nan;
        for icond = ["in","out","diff"]
            switch icond
                case 'in'; x0 = 0.06; cl = [0 0.015]; z = squeeze(nanmean(data.in));
                case 'out'; x0 = 0.38; cl = [0 0.015]; z = squeeze(nanmean(data.out));
                case 'diff'; x0 = 0.7; cl = [-1,1];
                    din = permute(data.in,[3 2 1]);
                    dout = permute(data.out,[3 2 1]);
                    [clusts, p, t, ~] = permutest(din,dout,1,[],[],1);
                    clustsel = clusts(p<0.05); sig = false(size(din,1),size(din,2));
                    for i = 1:numel(clustsel); sig(clustsel{i})=true; end
                    z = sign(squeeze(nanmean(din-dout,3))'); z(~sig') = 0;
            end
            ax = axes(fig,'Position',[x0, y0, 0.25, 0.24]); hold on;
            
            imagesc(SFC_brst_all.tds,SFC_brst_all.freq,z');
            arrayfun(@(x) plot([x x],flim,'--k','LineWidth',2), [0,0.5,1.5,2,3]);
            caxis(cl);
            set(gca,'YDir','normal');
            cb = colorbar;
            if strcmp(icond,'diff')
                colormap(gca,redblue); cb.Label.String = 'PPC Diff.';
            else
                colormap(gca,jet); cb.Label.String = 'PPC';
            end
            xlim(ax,tlim); ylim(flim);
            ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
            xlabel('Time from sample onset [s]')
            if strcmp(icond,'in'); ylabel('Frequency [Hz]'); end
            if strcmp(iband,'HighGamma'); title(icond,'FontSize',15); end
        end
        axes(fig,'Position',[0.05,y0,0.9,0.28],'Visible','off');
        ylabel(iband,'Color',c.(iband),'FontSize',20);
    end
    for icond = ["in","out","diff"]
        switch icond
            case 'in'; x0 = 0.7;
            case 'out'; x0 = 0.38;
            case 'diff'; x0 = 0.06;
        end
        axes(fig,'Position',[x0,0.06,0.28,0.89],'Visible','off');
        title(icond,'FontSize',20);
    end
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; y0 = 0.06;
            case 'LowGamma'; y0 = 0.38;
            case 'HighGamma'; y0 = 0.7;
        end
        axes(fig,'Position',[0.06,y0,0.89,0.24],'Visible','off');
        ylabel(iband,'FontSize',20,'Visible','on');
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outf,sprintf('SFC_brst_clust_%s_sig',ireg)),'-depsc');
    print(fullfile(outf,sprintf('SFC_brst_clust_%s_sig',ireg)),'-dpng');
end

%% Compare between conditions for non-interpolated
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint';
dirf = dir(fullfile(inf,'*.mat')); filesin = {dirf.name};
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst_unint_cond'; mkdir(outf);
outdirf = dir(fullfile(outf,'*.mat')); filesout = {outdirf.name};
files = setdiff(filesin,filesout);

% test channel
sort_spk_cond(inf,outf,filesin{4});

delete(gcp('nocreate'));
parpool(32);
parfor ifile = 1:numel(files)
    sort_spk_cond(inf,outf,files{ifile});
    fprintf('>>> Completed %s\n',files{ifile});
end

% summary
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst_unint_cond';
dirf = dir(fullfile(inf,'*.mat')); files = {dirf.name};
load('/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi/multi_mod.mat','multi_mod');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC';
SFC_cond_all = struct();
SFC_cond_all.files = files;
SFC_cond_all.channel = [];
SFC_cond_all.valid = multi_mod.taskmod;
load(fullfile(inf,files{1}),'SFC_cond');
SFC_cond_all.time = SFC_cond.time; SFC_cond_all.win = SFC_cond.win; SFC_cond_all.step = SFC_cond.step;
SFC_cond_all.freq = SFC_cond.freq;
SFC_cond_all.tds = SFC_cond.tds;
load(fullfile(inf,files{1}),'SFC_cond');
for icond = ["C","E","D","N","F","S"]
    SFC_cond_all.(icond) = nan(numel(files),length(SFC_cond_all.tds),length(SFC_cond_all.freq));
end
prog = 0.0;
fprintf('>>> Loading data: %3.0f%%\n',prog)
for ifile = 1:numel(files)
    load(fullfile(inf,files{ifile}),'SFC_cond');
    for icond = ["C","E","D","N","F","S"]
        SFC_cond_all.(icond)(ifile,:,:) = SFC_cond.(icond).PPC;
    end
    prog = ifile/numel(files)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,'SFC_cond_all'),'SFC_cond_all');

% Plot results
close all; fig = figure('Position',[0 0 800 600]);
regions = ["PFC","VIP"];
SFC_cond_all.region = cellfun(@(s) regions((str2double(s(13:14))>8)+1), SFC_cond_all.files,'uni',0);
for ireg = regions
    clf(fig,'reset')
    regsel = cellfun(@(s) strcmp(s,ireg),SFC_cond_all.region)&SFC_cond_all.valid';
    for icond = ["CvsE","FvsS","DvsN"]
        switch icond
            case 'CvsE'; conds = ["C","E"]; y0 = 0.7;
            case 'FvsS'; conds = ["F","S"]; y0 = 0.38;
            case 'DvsN'; conds = ["D","N"]; y0 = 0.06;
        end
        d1 = SFC_cond_all.(conds(1))(regsel,:,:);
        d2 = SFC_cond_all.(conds(2))(regsel,:,:);
        for ic = [conds,"Diff"]
            switch ic
                case conds(1); x0 = 0.06; z = squeeze(nanmean(d1)); cl = [-0.6,0.6];
                case conds(2); x0 = 0.38; z = squeeze(nanmean(d2)); cl = [-0.6,0.6];
                case 'Diff'; x0 = 0.7; z = squeeze(nanmean(d1-d2)); cl = [-0.1,0.1];
            end
            axes(fig,'Position',[x0 y0 0.24 0.24]); hold on; colormap(gca,jet);
            if ic=='Diff'; colormap(gca,redblue); end
            imagesc(SFC_cond_all.tds,SFC_cond_all.freq,z');
            set(gca,'YDir','normal','box','on','TickDir','out','XColor','k','YColor','k');
            arrayfun(@(x) plot([x x],[1,128],'--w'),[0 0.5 1.5 2 3]);
            xlim(SFC_cond_all.tds([1,end])); xlabel('Time from sample onset [s]');
            ylim(SFC_cond_all.freq([1,end]));
            %caxis(cl);
            ylabel('Frequency [Hz]'); title(ic);
            cb = colorbar('Location','eastoutside');
            cb.Label.String = 'PPC';
        end
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outf,sprintf('SFC_cond_%s_Diff',ireg)),'-dpng');
    print(fullfile(outf,sprintf('SFC_cond_%s_Diff',ireg)),'-depsc');
end

%%
function get_spktrgspctrm(sess)
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
load(fullfile(inf,sess),'data_prep');
% get sorted MUA spikes from all valid channels (852)
spkf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/003.MultiUnit';
dirspk = dir(fullfile(spkf,[sess,'*']));
filespk = {dirspk.name};
% get trial info
nexf = '/mnt/storage/xuanyu/MONKEY/Non-ion/spike_nexctx';
load(fullfile(nexf,sess),'nexctx');
% store root
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol';

% segmentation
cfg_spktrl = struct();
cfg_spktrl.timestampspersecond = data_prep.hdr.Fs*data_prep.hdr.TimeStampPerSample;
% get timestamp of sample onset (t0) from every trial
trlsel = nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6;
trlonI = nexctx.TrialStartInd(trlsel);
sidx = find(nexctx.EventCodes==25);
senstrig = arrayfun(@(i) sidx(find(sidx>i,1)), trlonI);
offset = nexctx.TrialStartTime(trlsel)-nexctx.EventTimes(senstrig);
cfg_spktrl.trl = [nexctx.TrialStartTime(trlsel)*cfg_spktrl.timestampspersecond,nexctx.TrialEndTime(trlsel)*cfg_spktrl.timestampspersecond,offset*cfg_spktrl.timestampspersecond];
cfg_spktrl.trlunit = 'timestamps';

% allogate spikes
spike = struct();
for i = 1:numel(filespk)
    load(fullfile(spkf,filespk{i}),'data_spk');
    spike.label{i} = filespk{i}(9:14);
    spike.waveform{i} = data_spk.waveform(data_spk.multiunit,:)';
    spike.waveformdimord = '{chan}_lead_time_spike';
    spike.timestamp{i} = double(data_spk.ts(data_spk.multiunit))/1e3*cfg_spktrl.timestampspersecond; % transform to timestamp
    spike.unit{i} = 'MUA';
end
evalc('spike = ft_spike_maketrials(cfg_spktrl,spike)');

% run spike-triggered interpolation
evalc('data_all = ft_appendspike([],data_prep, spike)');
% interpolate around spike
cfg_spkint              = [];
cfg_spkint.method       = 'linear'; % remove the replaced segment with interpolation
cfg_spkint.timwin       = [-0.002 0.002]; % remove 4 ms around every spike
% fourier transform by spike-triggered segments
cfg_fft              = [];
cfg_fft.method       = 'mtmconvol';
cfg_fft.output       = 'fourier';
cfg_fft.foi          = 2:128;
cfg_fft.timwin       = [-0.5 0.5]; % time window of 1s
cfg_fft.keeptrials   = 'yes';
cfg_fft.taper        = 'hanning';
cfg_fft.t_ftimwin    = 3./cfg_fft.foi;
cfg_fft.pad          = 'nextpow2';
cfg_fft.padtype      = 'zero';
for i = 1:numel(filespk)
    chansel = spike.label{i}; chanAD = sprintf('AD%s',chansel(5:6));
    cfg_spkint.spikechannel = chansel;
    cfg_spkint.channel = chanAD;
    % interpolate lfp
    evalc('data_i = ft_spiketriggeredinterpolation(cfg_spkint, data_all)');
    cfg_fft.spikechannel = chansel;
    cfg_fft.channel = chanAD;
    % spike-triggered fourier spectrogram
    evalc('stsConvol = ft_spiketriggeredspectrum(cfg_fft,data_i,spike)');
    save(fullfile(outf,strcat(sess,'-',chansel)),'stsConvol');
    fprintf('>>> Completed %s-%s\n',sess,chansel);
end
end

function get_spktrgspctrm_unint(sess)
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
load(fullfile(inf,sess),'data_prep');
% get sorted MUA spikes from all valid channels (852)
spkf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/003.MultiUnit';
dirspk = dir(fullfile(spkf,[sess,'*']));
filespk = {dirspk.name};
% get trial info
nexf = '/mnt/storage/xuanyu/MONKEY/Non-ion/spike_nexctx';
load(fullfile(nexf,sess),'nexctx');
% store root
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint';

% segmentation
cfg_spktrl = struct();
cfg_spktrl.timestampspersecond = data_prep.hdr.Fs*data_prep.hdr.TimeStampPerSample;
% get timestamp of sample onset (t0) from every trial
trlsel = nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6;
trlonI = nexctx.TrialStartInd(trlsel);
sidx = find(nexctx.EventCodes==25);
senstrig = arrayfun(@(i) sidx(find(sidx>i,1)), trlonI);
offset = nexctx.TrialStartTime(trlsel)-nexctx.EventTimes(senstrig);
cfg_spktrl.trl = [nexctx.TrialStartTime(trlsel)*cfg_spktrl.timestampspersecond,nexctx.TrialEndTime(trlsel)*cfg_spktrl.timestampspersecond,offset*cfg_spktrl.timestampspersecond];
cfg_spktrl.trlunit = 'timestamps';

% allogate spikes
spike = struct();
for i = 1:numel(filespk)
    load(fullfile(spkf,filespk{i}),'data_spk');
    spike.label{i} = filespk{i}(9:14);
    spike.waveform{i} = data_spk.waveform(data_spk.multiunit,:)';
    spike.waveformdimord = '{chan}_lead_time_spike';
    spike.timestamp{i} = double(data_spk.ts(data_spk.multiunit))/1e3*cfg_spktrl.timestampspersecond; % transform to timestamp
    spike.unit{i} = 'MUA';
end
evalc('spike = ft_spike_maketrials(cfg_spktrl,spike)');

% run spike-triggered interpolation
evalc('data_all = ft_appendspike([],data_prep, spike)');
% fourier transform by spike-triggered segments
cfg_fft              = [];
cfg_fft.method       = 'mtmconvol';
cfg_fft.output       = 'fourier';
cfg_fft.foi          = 2:128;
cfg_fft.timwin       = [-0.5 0.5]; % time window of 1s
cfg_fft.keeptrials   = 'yes';
cfg_fft.taper        = 'hanning';
cfg_fft.t_ftimwin    = 3./cfg_fft.foi;
cfg_fft.pad          = 'nextpow2';
cfg_fft.padtype      = 'zero';
for i = 1:numel(filespk)
    chansel = spike.label{i}; chanAD = sprintf('AD%s',chansel(5:6));
    cfg_fft.spikechannel = spike.label{i};
    cfg_fft.channel = chanAD;
    % spike-triggered fourier spectrogram
    evalc('stsConvol = ft_spiketriggeredspectrum(cfg_fft,data_all,spike)');
    save(fullfile(outf,strcat(sess,'-',chansel)),'stsConvol');
    fprintf('>>> Completed %s-%s\n',sess,chansel);
end
end

function get_ppcbias(sess,nshf,tds,win)
% Compute clustering bias by resampling the base frequency distribution for
% a fixed number of observations (nsamp), shuffling for nshf times
%
% Starting from pseudo-spikes, perform spike-triggered segmentation,
% spectrum and ppc.

inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
load(fullfile(inf,sess),'data_prep');
% get sorted MUA spikes from all valid channels (852)
spkf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/003.MultiUnit';
dirspk = dir(fullfile(spkf,[sess,'*']));
filespk = {dirspk.name};
% get trial info
nexf = '/mnt/storage/xuanyu/MONKEY/Non-ion/spike_nexctx';
load(fullfile(nexf,sess),'nexctx');
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
stsf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol';
% store root
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_bias';

% SETUP: segmentation
cfg_spktrl = struct();
cfg_spktrl.timestampspersecond = data_prep.hdr.Fs*data_prep.hdr.TimeStampPerSample;
% get timestamp of sample onset (t0) from every trial
trlsel = nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6;
trlonI = nexctx.TrialStartInd(trlsel);
sidx = find(nexctx.EventCodes==25);
senstrig = arrayfun(@(i) sidx(find(sidx>i,1)), trlonI);
offset = nexctx.TrialStartTime(trlsel)-nexctx.EventTimes(senstrig);
cfg_spktrl.trl = [nexctx.TrialStartTime(trlsel)*cfg_spktrl.timestampspersecond,nexctx.TrialEndTime(trlsel)*cfg_spktrl.timestampspersecond,offset*cfg_spktrl.timestampspersecond];
cfg_spktrl.trlunit = 'timestamps';
%
trlsel = nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6;
trlinfo = nexctx.TrialResponseErrors(trlsel);
% SETUP: fourier transform by spike-triggered segments
cfg_fft              = [];
cfg_fft.method       = 'mtmconvol';
cfg_fft.output       = 'fourier';
cfg_fft.foi          = 4:90;
cfg_fft.timwin       = [-0.5 0.5]; % time window of 1s
cfg_fft.keeptrials   = 'yes';
cfg_fft.taper        = 'hanning';
cfg_fft.t_ftimwin    = 3./cfg_fft.foi;
cfg_fft.spikechannel = 'all';
cfg_fft.pad          = 'nextpow2';
cfg_fft.padtype      = 'zero';
% SETUP: compute PPC with gliding window
cfg_ppc               = [];
cfg_ppc.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg_ppc.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg_ppc.timwin        = 'all';

% allogate spikes
spike = struct();
% output
SFC_bias = struct();
SFC_bias.channel = filespk;
SFC_bias.time = data_prep.time;
SFC_bias.tds = tds; SFC_bias.win = win;
for i = 1:numel(filespk)
    load(fullfile(spkf,filespk{i}),'data_spk');
    chanAD = [sess,'-AD',filespk{i}(13:14)];
    load(fullfile(brstf,chanAD),'data_burst');
    
    % perform spike train segmentation
    spike.label{1} = filespk{i}(9:14);
    spike.waveformdimord = '{chan}_lead_time_spike';
    spike.unit{1} = 'MUA';
    tend = data_spk.ts(end)/1e3*cfg_spktrl.timestampspersecond;
    ts = sum(data_spk.multiunit);
    cfg_fft.channel = ['AD',filespk{i}(13:14)];
    cfg_ppc.trial = trlinfo==0&~data_burst.badtrials'; % only correct and valid trials taken
    % output
    if i == 1
        stsname = sprintf('%s-%s',filespk{i}(1:7),filespk{i}(9:end));
        load(fullfile(stsf,stsname),'stsConvol');
        SFC_bias.freq = stsConvol.freq;
        SFC_bias.SFC = nan(nshf,numel(filespk),length(tds),length(stsConvol.freq));
        SFC_bias.nspike = nan(nshf,numel(filespk),length(tds));
    end
    for ishf = 1:nshf
        % randomize timestamps
        tr = randi(tend,ts,1);
        spike.timestamp{i} = tr;
        %         spike = ft_spike_maketrials(cfg_spktrl,spike); % with output
        evalc('spike = ft_spike_maketrials(cfg_spktrl,spike)');
        % spike-triggered fourier spectrogram
        %         stsConvol = ft_spiketriggeredspectrum(cfg_fft,data_prep,spike); % with output
        evalc('stsConvol = ft_spiketriggeredspectrum(cfg_fft,data_prep,spike)');
        % time-resolved PPC
        for ti = 1:length(tds)
            cfg_ppc.latency   = tds(ti)+win/2e3*[-1,1];
            %             statSts = ft_spiketriggeredspectrum_stat(cfg_ppc,stsConvol); % with output
            evalc('statSts = ft_spiketriggeredspectrum_stat(cfg_ppc,stsConvol);');
            SFC_bias.nspike(ishf,i,ti) = statSts.nspikes(1);
            if statSts.nspikes(1)<50; continue; end
            SFC_bias.SFC(ishf,i,ti,:) = statSts.ppc0;
        end
    end
end
save(fullfile(outf,sess),'SFC_bias');
end

function sort_spk(inf,outf,chansig)
% sort spikes by bursts (from the same channel)
chanAD = [chansig(1:8),'AD',chansig(13:14)];
load(fullfile(inf,chansig),'stsConvol');
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(brstf,chanAD),'data_burst');
brsts = data_burst.trialinfo.bursts;

% output
SFC_brst = struct();
SFC_brst.channel = chanAD;

bands = ["Beta","LowGamma","HighGamma"];
for iband = bands
    SFC_brst.(iband) = [];
    switch iband
        case 'HighGamma'; band_sel = [60 90];
        case 'LowGamma'; band_sel = [35 60];
        case 'Beta'; band_sel = [15 35];
    end
    brst_sel = cellfun(@(b) b(b.f>band_sel(1)&b.f<band_sel(2),:),brsts,'uni',0);
    inlist = false(size(stsConvol.trial{1}));
    for itrl = 1:numel(brst_sel)
        spkseltrl = stsConvol.trial{1}==itrl;
        bursts = brst_sel{itrl}; spks = stsConvol.time{1}(spkseltrl);
        brst_fwhm = arrayfun(@(sd) gauss_fwfracm(sd,1/2),bursts.t_sd);
        inlist(spkseltrl) = arrayfun(@(spk) any(arrayfun(@(mu,sd) spk>(mu-sd)&spk<(mu+sd),bursts.t,brst_fwhm/2)),spks);
    end
    SFC_brst.(iband).inlist = inlist;
end
save(fullfile(outf,chansig),'SFC_brst');
end

function sort_spk_cond(inf,outf,chansig)
chanAD = [chansig(1:8),'AD',chansig(13:14)];
load(fullfile(inf,chansig),'stsConvol');
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(brstf,chanAD),'data_burst');
brsts = data_burst.trialinfo.bursts;
trlinfo = data_burst.trialinfo;
RTf = '/mnt/storage/xuanyu/MONKEY/Non-ion/13.PerfOCP/ReactionTime';
load(fullfile(RTf,chansig(1:7)),'sess_RT');
trlinfo.RT = sess_RT.RT;
nshf = 100;
for i = 1:nshf
    [TRL.C{i},TRL.E{i}] = sortCE(trlinfo,data_burst.badtrials);
    [TRL.D{i},TRL.N{i}] = sortDN(trlinfo,data_burst.badtrials);
end
[TRL.F,TRL.S] = sortRT(trlinfo,trlinfo.RT,data_burst.badtrials); % quartile

% compute PPC with gliding window
cfg_ppc               = [];
cfg_ppc.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg_ppc.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg_ppc.timwin        = 'all'; % compute over all available spikes in the window, can actually do time-resolved

% output
SFC_cond = struct();
SFC_cond.channel = chanAD;
SFC_cond.time = -0.5:1e-3:3.2; SFC_cond.step = 250; SFC_cond.win = 500;
SFC_cond.tds = downsample(SFC_cond.time,SFC_cond.step);
SFC_cond.freq = stsConvol.freq;

for icond = ["C","E","D","N"]
    SFC_cond.(icond).nspike_perm = nan(nshf,length(SFC_cond.tds));
    SFC_cond.(icond).PPC_perm = nan(nshf,length(SFC_cond.tds),length(SFC_cond.freq));
    for i = 1:nshf
        cfg_ppc.trials = TRL.(icond){i};
        for ti = 1:length(SFC_cond.tds)
            cfg_ppc.latency   = SFC_cond.tds(ti)+SFC_cond.win/2e3*[-1,1];
            evalc('statSts = ft_spiketriggeredspectrum_stat(cfg_ppc,stsConvol);');
            SFC_cond.(icond).nspike_perm(i,ti,:) = statSts.nspikes(1);
            if statSts.nspikes(1)>50; SFC_cond.(icond).PPC_perm(i,ti,:) = statSts.ppc0; end
        end
    end
    SFC_cond.(icond).PPC = squeeze(nanmean(SFC_cond.(icond).PPC_perm));
end
for icond = ["F","S"]
    SFC_cond.(icond).nspike = nan(length(SFC_cond.tds));
    SFC_cond.(icond).PPC = nan(length(SFC_cond.tds),length(SFC_cond.freq));
    cfg_ppc.trial = TRL.(icond);
    for ti = 1:length(SFC_cond.tds)
        cfg_ppc.latency   = SFC_cond.tds(ti)+SFC_cond.win/2e3*[-1,1];
        evalc('statSts = ft_spiketriggeredspectrum_stat(cfg_ppc,stsConvol);');
        SFC_cond.(icond).nspike_(ti,:) = statSts.nspikes(1);
        if statSts.nspikes(1)>50; SFC_cond.(icond).PPC(ti,:) = statSts.ppc0; end
    end
end
save(fullfile(outf,chansig),'SFC_cond');
end
