% compute burst-modulated cross-regional spike-field coupling, which should
% be free from power-phase artifact and spike bleeding, while relating to
% our previous results (Daniel & Jacob, 2018)
clear; close all; clc;
% ft_preprocessing and ft_definetrial already done, see 0.TrialScreening
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan'; mkdir(outf);

% % test session
% get_spktrgspctrm_crsschan('R120424');

delete(gcp('nocreate'));
parpool(32);
parfor isess = 1:numel(sesses)
    sess = sesses{isess}(1:7);
    get_spktrgspctrm_crsschan(sess);
end

%% summary by region and perform SFC analysis: time-resolved, not sorted
clear; close all; clc;
strname = 'SFC_tempres_unsort';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum'); % load channel summary for the trialinfos of all sessions
[trlinfo.session,IA] = unique(cellfun(@(s) s(1:7),ChanSum.channame,'uni',0));
trlinfo.trialinfo = ChanSum.trlinfo(IA);
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat'); % load PFC locations
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
SFC_sum = struct();
SFC_sum.session = sesses;
load(fullfile(inf,sesses{1}),'stsConvol');
SFC_sum.freq = stsConvol.freq;
SFC_sum.spksums = cell2table(cell(0,4),'VariableNames',{'session','spkchan','time','trial'});
SFC_sum.trlinfo = struct2table(trlinfo); % store trialinfos of all sessions
SFC_sum.PFC_PFC = cell2table(cell(0,8),'VariableNames',{'session','spkchan','lfpchan','spkchan_loc','lfpchan_loc','distance','ppc','nspk'});
SFC_sum.PFC_VIP = cell2table(cell(0,5),'VariableNames',{'session','spkchan','lfpchan','ppc','nspk'});
SFC_sum.VIP_PFC = SFC_sum.PFC_VIP;
SFC_sum.VIP_VIP = SFC_sum.PFC_VIP;
% parameters for SFC
SFC_sum.cfg = struct();
cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 0.25; % gliding window analysis, window size of 250ms
cfg.winstepsize   = 0.1; % steps of 100ms
cfg.latency       = [-0.55,3.25]; % to keep alignment to zero
SFC_sum.cfg = cfg;
SFC_sum.cfg.time = -0.5:cfg.winstepsize:3.2;
% creates an error log
errorlog = fopen(fullfile(outf,[strname,'_err.txt']),'w');
prog = 0.0;
fprintf('>>> Loading data: %3.0f%%\n',prog)
spksum = struct();
for isess = 1:numel(sesses)
    sessname = sesses{isess}(1:end-4);
    load(fullfile(inf,sessname),'stsConvol'); % load spike-triggered spectrum phases
    % compute time-resolved SFC
    % get summary for spike channels
    spkchans = stsConvol.label; spkPFC = cellfun(@(s) str2double(s(5:6))<9,spkchans);
    spksum.session = repmat(sessname,numel(spkchans),1); spksum.spkchan = spkchans'; spksum.time = stsConvol.time'; spksum.trial = stsConvol.trial';
    SFC_sum.spksums = [SFC_sum.spksums;struct2table(spksum)];
    lfpchans = stsConvol.lfplabel; lfpPFC = cellfun(@(s) str2double(s(3:4))<9,lfpchans);
    % get trial info
    trlinfosess = SFC_sum.trlinfo.trialinfo{isess};
    % arrange data pairs by region
    for spkreg = ["PFC","VIP"]
        switch spkreg
            case 'PFC'; spklst = spkPFC;
            case 'VIP'; spklst = ~spkPFC;
        end
        for lfpreg = ["PFC","VIP"]
            switch lfpreg
                case 'PFC'; lfplst = lfpPFC;
                case 'VIP'; lfplst = ~lfpPFC;
            end
            cond = strcat(spkreg,'_',lfpreg);
            data = struct();
            data.session = repmat(sessname,sum(spklst)*sum(lfplst),1);
            data.spkchan = repmat(spkchans(spklst),sum(lfplst),1); data.spkchan = data.spkchan(:);
            data.lfpchan = repmat(lfpchans(lfplst),1,sum(spklst)); data.lfpchan = data.lfpchan(:);
            if strcmp(spkreg,'PFC')&&strcmp(lfpreg,'PFC') % where location is available
                pat = pattern_PFC{sess.sess_pat(cellfun(@(s) strcmp(s,sessname),sess.sess_names))};
                data.spkchan_loc = cellfun(@(s) pat{str2double(s(5:6))},data.spkchan,'uni',0);
                data.lfpchan_loc = cellfun(@(s) pat{str2double(s(3:4))},data.lfpchan,'uni',0);
                data.distance = cellfun(@(spkchan,lfpchan) sqrt(sum((spkchan-lfpchan).^2)),data.spkchan_loc,data.lfpchan_loc);
            end
            data.ppc = cell(sum(lfplst),sum(spklst));
            data.nspk = cell(sum(lfplst),sum(spklst));
            for ilfp = 1:sum(lfplst)
                y = find(lfplst,ilfp); cfg.channel = lfpchans(y(end));
                load(fullfile(brstf,sprintf('%s-AD%s',sessname,cfg.channel{1}(3:4))),'data_burst');
                lfpbadtrl = data_burst.badtrials;
                for ispk = 1:sum(spklst)
                    x = find(spklst,ispk);  cfg.spikechannel = spkchans(x(end));
                    cfg.trials = trlinfosess.errorcode==0 & ~lfpbadtrl';
                    try % if no spikes catched, discart
                        evalc('statSts = ft_spiketriggeredspectrum_stat(cfg,stsConvol);');
                        data.ppc{ilfp,ispk} = squeeze(statSts.ppc0);
                        data.nspk{ilfp,ispk} = squeeze(statSts.nspikes);
                        data.ppc{ilfp,ispk}(data.nspk{ilfp,ispk}<50) = nan; % exclude windows where nspk<50;
                    catch e
                        fprintf(errorlog,'Error catched for session %s, spike channel %s to lfp channel %s \n\t Error message: %s\n',sessname,cfg.spikechannel{1},cfg.channel{1},e.message);
                    end
                end
            end
            data.ppc = data.ppc(:); % reshape to align with other domains
            data.nspk = data.nspk(:); % reshape to align with other domains
            SFC_sum.(cond) = [SFC_sum.(cond);struct2table(data)];
        end
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,strname),'SFC_sum','-v7.3');

%% summary by region and perform SFC analysis: time-resolved, not sorted, error trials
clear; close all; clc;
strname = 'SFC_tempres_unsort_error';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum'); % load channel summary for the trialinfos of all sessions
[trlinfo.session,IA] = unique(cellfun(@(s) s(1:7),ChanSum.channame,'uni',0));
trlinfo.trialinfo = ChanSum.trlinfo(IA);
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat'); % load PFC locations
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
SFC_sum = struct();
SFC_sum.session = sesses;
load(fullfile(inf,sesses{1}),'stsConvol');
SFC_sum.freq = stsConvol.freq;
SFC_sum.spksums = cell2table(cell(0,4),'VariableNames',{'session','spkchan','time','trial'});
SFC_sum.trlinfo = struct2table(trlinfo); % store trialinfos of all sessions
SFC_sum.PFC_PFC = cell2table(cell(0,8),'VariableNames',{'session','spkchan','lfpchan','spkchan_loc','lfpchan_loc','distance','ppc','nspk'});
SFC_sum.PFC_VIP = cell2table(cell(0,5),'VariableNames',{'session','spkchan','lfpchan','ppc','nspk'});
SFC_sum.VIP_PFC = SFC_sum.PFC_VIP;
SFC_sum.VIP_VIP = SFC_sum.PFC_VIP;
% parameters for SFC
SFC_sum.cfg = struct();
cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 0.25; % gliding window analysis, window size of 250ms
cfg.winstepsize   = 0.1; % steps of 100ms
cfg.latency       = [-0.55,3.25]; % to keep alignment to zero
SFC_sum.cfg = cfg;
SFC_sum.cfg.time = -0.5:cfg.winstepsize:3.2;
% creates an error log
errorlog = fopen(fullfile(outf,[strname,'_err.txt']),'w');
prog = 0.0;
fprintf('>>> Loading data: %3.0f%%\n',prog)
spksum = struct();
for isess = 1:numel(sesses)
    sessname = sesses{isess}(1:end-4);
    load(fullfile(inf,sessname),'stsConvol'); % load spike-triggered spectrum phases
    % compute time-resolved SFC
    % get summary for spike channels
    spkchans = stsConvol.label; spkPFC = cellfun(@(s) str2double(s(5:6))<9,spkchans);
    spksum.session = repmat(sessname,numel(spkchans),1); spksum.spkchan = spkchans'; spksum.time = stsConvol.time'; spksum.trial = stsConvol.trial';
    SFC_sum.spksums = [SFC_sum.spksums;struct2table(spksum)];
    lfpchans = stsConvol.lfplabel; lfpPFC = cellfun(@(s) str2double(s(3:4))<9,lfpchans);
    % get trial info
    trlinfosess = SFC_sum.trlinfo.trialinfo{isess};
    % arrange data pairs by region
    for spkreg = ["PFC","VIP"]
        switch spkreg
            case 'PFC'; spklst = spkPFC;
            case 'VIP'; spklst = ~spkPFC;
        end
        for lfpreg = ["PFC","VIP"]
            switch lfpreg
                case 'PFC'; lfplst = lfpPFC;
                case 'VIP'; lfplst = ~lfpPFC;
            end
            cond = strcat(spkreg,'_',lfpreg);
            data = struct();
            data.session = repmat(sessname,sum(spklst)*sum(lfplst),1);
            data.spkchan = repmat(spkchans(spklst),sum(lfplst),1); data.spkchan = data.spkchan(:);
            data.lfpchan = repmat(lfpchans(lfplst),1,sum(spklst)); data.lfpchan = data.lfpchan(:);
            if strcmp(spkreg,'PFC')&&strcmp(lfpreg,'PFC') % where location is available
                pat = pattern_PFC{sess.sess_pat(cellfun(@(s) strcmp(s,sessname),sess.sess_names))};
                data.spkchan_loc = cellfun(@(s) pat{str2double(s(5:6))},data.spkchan,'uni',0);
                data.lfpchan_loc = cellfun(@(s) pat{str2double(s(3:4))},data.lfpchan,'uni',0);
                data.distance = cellfun(@(spkchan,lfpchan) sqrt(sum((spkchan-lfpchan).^2)),data.spkchan_loc,data.lfpchan_loc);
            end
            data.ppc = cell(sum(lfplst),sum(spklst));
            data.nspk = cell(sum(lfplst),sum(spklst));
            for ilfp = 1:sum(lfplst)
                y = find(lfplst,ilfp); cfg.channel = lfpchans(y(end));
                load(fullfile(brstf,sprintf('%s-AD%s',sessname,cfg.channel{1}(3:4))),'data_burst');
                lfpbadtrl = data_burst.badtrials;
                for ispk = 1:sum(spklst)
                    x = find(spklst,ispk);  cfg.spikechannel = spkchans(x(end));
                    cfg.trials = trlinfosess.errorcode~=0 & ~lfpbadtrl';
                    try % if no spikes catched, discart
                        evalc('statSts = ft_spiketriggeredspectrum_stat(cfg,stsConvol);');
                        data.ppc{ilfp,ispk} = squeeze(statSts.ppc0);
                        data.nspk{ilfp,ispk} = squeeze(statSts.nspikes);
                        data.ppc{ilfp,ispk}(data.nspk{ilfp,ispk}<50) = nan; % exclude windows where nspk<50;
                    catch e
                        fprintf(errorlog,'Error catched for session %s, spike channel %s to lfp channel %s \n\t Error message: %s\n',sessname,cfg.spikechannel{1},cfg.channel{1},e.message);
                    end
                end
            end
            data.ppc = data.ppc(:); % reshape to align with other domains
            data.nspk = data.nspk(:); % reshape to align with other domains
            SFC_sum.(cond) = [SFC_sum.(cond);struct2table(data)];
        end
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,strname),'SFC_sum','-v7.3');

%% summary by region and perform SFC analysis: epoch, not sorted
clear; close all; clc;
strname = 'SFC_epoch_unsort';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum'); % load channel summary for the trialinfos of all sessions
[trlinfo.session,IA] = unique(cellfun(@(s) s(1:7),ChanSum.channame,'uni',0));
trlinfo.trialinfo = ChanSum.trlinfo(IA);
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat'); % load PFC locations
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
SFC_sum = struct();
SFC_sum.session = sesses;
load(fullfile(inf,sesses{1}),'stsConvol');
SFC_sum.freq = stsConvol.freq;
SFC_sum.spksums = cell2table(cell(0,4),'VariableNames',{'session','spkchan','time','trial'});
SFC_sum.trlinfo = struct2table(trlinfo); % store trialinfos of all sessions
SFC_sum.PFC_PFC = cell2table(cell(0,8),'VariableNames',{'session','spkchan','lfpchan','spkchan_loc','lfpchan_loc','distance','ppc','nspk'});
SFC_sum.PFC_VIP = cell2table(cell(0,5),'VariableNames',{'session','spkchan','lfpchan','ppc','nspk'});
SFC_sum.VIP_PFC = SFC_sum.PFC_VIP;
SFC_sum.VIP_VIP = SFC_sum.PFC_VIP;
% parameters for SFC
SFC_sum.cfg = struct();
cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 'all'; % gliding window analysis, window size of 250ms
SFC_sum.cfg = cfg;
SFC_sum.cfg.epoch = {[-0.5,0],[0.1,0.6],[0.6,1.6],[1.6,2.1],[2.1,3.1]};
SFC_sum.cfg.epoch_name = {'Fixa','Samp','Mem1','Dist','Mem2'};
% creates an error log
errorlog = fopen(fullfile(outf,[strname,'_err.txt']),'w');
prog = 0.0;
fprintf('>>> Loading data: %3.0f%%\n',prog)
spksum = struct();
for isess = 1:numel(sesses)
    sessname = sesses{isess}(1:end-4);
    load(fullfile(inf,sessname),'stsConvol'); % load spike-triggered spectrum phases
    % compute time-resolved SFC
    % get summary for spike channels
    spkchans = stsConvol.label; spkPFC = cellfun(@(s) str2double(s(5:6))<9,spkchans);
    spksum.session = repmat(sessname,numel(spkchans),1); spksum.spkchan = spkchans'; spksum.time = stsConvol.time'; spksum.trial = stsConvol.trial';
    SFC_sum.spksums = [SFC_sum.spksums;struct2table(spksum)];
    lfpchans = stsConvol.lfplabel; lfpPFC = cellfun(@(s) str2double(s(3:4))<9,lfpchans);
    % get trial info
    trlinfosess = SFC_sum.trlinfo.trialinfo{isess};
    % arrange data pairs by region
    for spkreg = ["PFC","VIP"]
        switch spkreg
            case 'PFC'; spklst = spkPFC;
            case 'VIP'; spklst = ~spkPFC;
        end
        for lfpreg = ["PFC","VIP"]
            switch lfpreg
                case 'PFC'; lfplst = lfpPFC;
                case 'VIP'; lfplst = ~lfpPFC;
            end
            cond = strcat(spkreg,'_',lfpreg);
            data = struct();
            data.session = repmat(sessname,sum(spklst)*sum(lfplst),1);
            data.spkchan = repmat(spkchans(spklst),sum(lfplst),1); data.spkchan = data.spkchan(:);
            data.lfpchan = repmat(lfpchans(lfplst),1,sum(spklst)); data.lfpchan = data.lfpchan(:);
            if strcmp(spkreg,'PFC')&&strcmp(lfpreg,'PFC') % where location is available
                pat = pattern_PFC{sess.sess_pat(cellfun(@(s) strcmp(s,sessname),sess.sess_names))};
                data.spkchan_loc = cellfun(@(s) pat{str2double(s(5:6))},data.spkchan,'uni',0);
                data.lfpchan_loc = cellfun(@(s) pat{str2double(s(3:4))},data.lfpchan,'uni',0);
                data.distance = cellfun(@(spkchan,lfpchan) sqrt(sum((spkchan-lfpchan).^2)),data.spkchan_loc,data.lfpchan_loc);
            end
            data.ppc = cell(sum(lfplst),sum(spklst));
            data.nspk = cell(sum(lfplst),sum(spklst));
            for ilfp = 1:sum(lfplst)
                y = find(lfplst,ilfp); cfg.channel = lfpchans(y(end));
                load(fullfile(brstf,sprintf('%s-AD%s',sessname,cfg.channel{1}(3:4))),'data_burst');
                lfpbadtrl = data_burst.badtrials;
                for ispk = 1:sum(spklst)
                    x = find(spklst,ispk);  cfg.spikechannel = spkchans(x(end));
                    cfg.trials = trlinfosess.errorcode==0 & ~lfpbadtrl';
                    for iep = 1:5
                        cfg.latency = SFC_sum.cfg.epoch{iep};
                        try % if no spikes catched, discart
                            evalc('statSts = ft_spiketriggeredspectrum_stat(cfg,stsConvol);');
                            data.ppc{ilfp,ispk}(:,iep) = squeeze(statSts.ppc0);
                            data.nspk{ilfp,ispk}(:,iep) = squeeze(statSts.nspikes);
                        catch e
                            fprintf(errorlog,'Error catched for session %s, spike channel %s to lfp channel %s, at epoch %s \n\t Error message: %s\n',sessname,cfg.spikechannel{1},cfg.channel{1},SFC_sum.cfg.epoch_name{iep},e.message);
                        end
                    end
                    data.ppc{ilfp,ispk}(data.nspk{ilfp,ispk}<50) = nan; % exclude windows where nspk<50;
                end
            end
            data.ppc = data.ppc(:); % reshape to align with other domains
            data.nspk = data.nspk(:); % reshape to align with other domains
            SFC_sum.(cond) = [SFC_sum.(cond);struct2table(data)];
        end
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,strname),'SFC_sum','-v7.3');

%% summary by region and perform SFC analysis: all-trl, not sorted
clear; close all; clc;
strname = 'SFC_alltrl_unsort';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum'); % load channel summary for the trialinfos of all sessions
[trlinfo.session,IA] = unique(cellfun(@(s) s(1:7),ChanSum.channame,'uni',0));
trlinfo.trialinfo = ChanSum.trlinfo(IA);
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat'); % load PFC locations
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
SFC_sum = struct();
SFC_sum.session = sesses;
load(fullfile(inf,sesses{1}),'stsConvol');
SFC_sum.freq = stsConvol.freq;
SFC_sum.spksums = cell2table(cell(0,4),'VariableNames',{'session','spkchan','time','trial'});
SFC_sum.trlinfo = struct2table(trlinfo); % store trialinfos of all sessions
SFC_sum.PFC_PFC = cell2table(cell(0,8),'VariableNames',{'session','spkchan','lfpchan','spkchan_loc','lfpchan_loc','distance','ppc','nspk'});
SFC_sum.PFC_VIP = cell2table(cell(0,5),'VariableNames',{'session','spkchan','lfpchan','ppc','nspk'});
SFC_sum.VIP_PFC = SFC_sum.PFC_VIP;
SFC_sum.VIP_VIP = SFC_sum.PFC_VIP;
% parameters for SFC
SFC_sum.cfg = struct();
cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 'all'; % gliding window analysis, window size of 250ms
cfg.latency       = [-0.5,3.2]; % all trial time taken
SFC_sum.cfg = cfg;
% creates an error log
errorlog = fopen(fullfile(outf,[strname,'_err.txt']),'w');
prog = 0.0;
fprintf('>>> Loading data %s: %3.0f%%\n',strname,prog)
spksum = struct();
for isess = 1:numel(sesses)
    sessname = sesses{isess}(1:end-4);
    load(fullfile(inf,sessname),'stsConvol'); % load spike-triggered spectrum phases
    % compute time-resolved SFC
    % get summary for spike channels
    spkchans = stsConvol.label; spkPFC = cellfun(@(s) str2double(s(5:6))<9,spkchans);
    spksum.session = repmat(sessname,numel(spkchans),1); spksum.spkchan = spkchans'; spksum.time = stsConvol.time'; spksum.trial = stsConvol.trial';
    SFC_sum.spksums = [SFC_sum.spksums;struct2table(spksum)];
    lfpchans = stsConvol.lfplabel; lfpPFC = cellfun(@(s) str2double(s(3:4))<9,lfpchans);
    % get trial info
    trlinfosess = SFC_sum.trlinfo.trialinfo{isess};
    % arrange data pairs by region
    for spkreg = ["PFC","VIP"]
        switch spkreg
            case 'PFC'; spklst = spkPFC;
            case 'VIP'; spklst = ~spkPFC;
        end
        for lfpreg = ["PFC","VIP"]
            switch lfpreg
                case 'PFC'; lfplst = lfpPFC;
                case 'VIP'; lfplst = ~lfpPFC;
            end
            cond = strcat(spkreg,'_',lfpreg);
            data = struct();
            data.session = repmat(sessname,sum(spklst)*sum(lfplst),1);
            data.spkchan = repmat(spkchans(spklst),sum(lfplst),1); data.spkchan = data.spkchan(:);
            data.lfpchan = repmat(lfpchans(lfplst),1,sum(spklst)); data.lfpchan = data.lfpchan(:);
            if strcmp(spkreg,'PFC')&&strcmp(lfpreg,'PFC') % where location is available
                pat = pattern_PFC{sess.sess_pat(cellfun(@(s) strcmp(s,sessname),sess.sess_names))};
                data.spkchan_loc = cellfun(@(s) pat{str2double(s(5:6))},data.spkchan,'uni',0);
                data.lfpchan_loc = cellfun(@(s) pat{str2double(s(3:4))},data.lfpchan,'uni',0);
                data.distance = cellfun(@(spkchan,lfpchan) sqrt(sum((spkchan-lfpchan).^2)),data.spkchan_loc,data.lfpchan_loc);
            end
            data.ppc = cell(sum(lfplst),sum(spklst));
            data.nspk = cell(sum(lfplst),sum(spklst));
            for ilfp = 1:sum(lfplst)
                y = find(lfplst,ilfp); cfg.channel = lfpchans(y(end));
                load(fullfile(brstf,sprintf('%s-AD%s',sessname,cfg.channel{1}(3:4))),'data_burst');
                lfpbadtrl = data_burst.badtrials;
                for ispk = 1:sum(spklst)
                    x = find(spklst,ispk);  cfg.spikechannel = spkchans(x(end));
                    cfg.trials = trlinfosess.errorcode==0 & ~lfpbadtrl';
                    try % if no spikes catched, discart
                        evalc('statSts = ft_spiketriggeredspectrum_stat(cfg,stsConvol);');
                        data.ppc{ilfp,ispk} = squeeze(statSts.ppc0);
                        data.nspk{ilfp,ispk} = squeeze(statSts.nspikes);
                    catch e
                        fprintf(errorlog,'Error catched for session %s, spike channel %s to lfp channel %s, at epoch %s \n\t Error message: %s\n',sessname,cfg.spikechannel{1},cfg.channel{1},SFC_sum.cfg.epoch_name{iep},e.message);
                    end
                    data.ppc{ilfp,ispk}(data.nspk{ilfp,ispk}<50) = nan; % exclude windows where nspk<50;
                end
            end
            data.ppc = data.ppc(:); % reshape to align with other domains
            data.nspk = data.nspk(:); % reshape to align with other domains
            SFC_sum.(cond) = [SFC_sum.(cond);struct2table(data)];
        end
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,strname),'SFC_sum','-v7.3');

%% summary by region and perform SFC analysis: all-trl, burst sorted
clear; close all; clc;
strname = 'SFC_alltrl_sorted';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
inf_sts = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/statSts_SFC_alltrl_sorted';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum'); % load channel summary for the trialinfos of all sessions
[trlinfo.session,IA] = unique(cellfun(@(s) s(1:7),ChanSum.channame,'uni',0));
trlinfo.trialinfo = ChanSum.trlinfo(IA);
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
SFC_sum = struct();
SFC_sum.session = sesses;
load(fullfile(inf,sesses{1}),'stsConvol');
SFC_sum.freq = stsConvol.freq;
SFC_sum.spksums = cell2table(cell(0,4),'VariableNames',{'session','spkchan','time','trial'});
SFC_sum.trlinfo = struct2table(trlinfo); % store trialinfos of all sessions
SFC_sum.PFC_PFC = cell2table(cell(0,8),'VariableNames',{'session','spkchan','lfpchan','spkchan_loc','lfpchan_loc','distance','ppc','nspk'});
SFC_sum.PFC_VIP = cell2table(cell(0,5),'VariableNames',{'session','spkchan','lfpchan','ppc','nspk'});
SFC_sum.VIP_PFC = SFC_sum.PFC_VIP;
SFC_sum.VIP_VIP = SFC_sum.PFC_VIP;
% parameters for SFC
SFC_sum.cfg = struct();
cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 'all'; % gliding window analysis, window size of 250ms
cfg.latency       = [-0.5,3.2]; % all trial time taken
SFC_sum.cfg = cfg;
SFC_sum.cfg.Bands = ["Beta","LowGamma","HighGamma"];
SFC_sum.cfg.conds = ["in","out"];
% creates an error log
errorlog = fopen(fullfile(outf,[strname,'_err.txt']),'w');
% process with parpool
% % test session
% SFC_alltrl_sorted(cfg,sesses{76},SFC_sum.trlinfo.trialinfo{76},SFC_sum.cfg.Bands,SFC_sum.cfg.conds,SFC_sum.freq,errorlog);
delete(gcp('nocreate'));
parpool(32);
parfor isess = 1:numel(sesses)
    try
        SFC_alltrl_sorted(cfg,sesses{isess},SFC_sum.trlinfo.trialinfo{isess},SFC_sum.cfg.Bands,SFC_sum.cfg.conds,SFC_sum.freq,errorlog);
        fprintf('>>> Completed %s\n',sesses{isess});
    catch e
        fprintf('!!! Error with session %s: %s\n',sesses{isess},e.message);
    end
end
% load data
prog = 0.0;
fprintf('>>> Loading data %s: %3.0f%%\n',strname,prog)
for isess = 1:numel(sesses)
    sessname = sesses{isess}(1:end-4);
    load(fullfile(inf_sts,sessname),'spksum','data'); % load processed data
    % get summary for spike channels
    SFC_sum.spksums = [SFC_sum.spksums;struct2table(spksum)];
    % arrange data pairs by region
    for spkreg = ["PFC","VIP"]
        for lfpreg = ["PFC","VIP"]
            cond = strcat(spkreg,'_',lfpreg);
            SFC_sum.(cond) = [SFC_sum.(cond);struct2table(data.(cond))];
        end
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,strname),'SFC_sum','-v7.3');

%% summary by region and perform SFC analysis: time-resolved, burst sorted
clear; close all; clc;
strname = 'SFC_tempres_sorted';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
dirf = dir(fullfile(inf,'*.mat'));
sesses = {dirf.name};
inf_sts = sprintf('/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/statSts_%s',strname);
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum'); % load channel summary for the trialinfos of all sessions
[trlinfo.session,IA] = unique(cellfun(@(s) s(1:7),ChanSum.channame,'uni',0));
trlinfo.trialinfo = ChanSum.trlinfo(IA);
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
SFC_sum = struct();
SFC_sum.session = sesses;
load(fullfile(inf,sesses{1}),'stsConvol');
SFC_sum.freq = stsConvol.freq;
SFC_sum.spksums = cell2table(cell(0,4),'VariableNames',{'session','spkchan','time','trial'});
SFC_sum.trlinfo = struct2table(trlinfo); % store trialinfos of all sessions
SFC_sum.PFC_PFC = cell2table(cell(0,8),'VariableNames',{'session','spkchan','lfpchan','spkchan_loc','lfpchan_loc','distance','ppc','nspk'});
SFC_sum.PFC_VIP = cell2table(cell(0,5),'VariableNames',{'session','spkchan','lfpchan','ppc','nspk'});
SFC_sum.VIP_PFC = SFC_sum.PFC_VIP;
SFC_sum.VIP_VIP = SFC_sum.PFC_VIP;
% parameters for SFC
SFC_sum.cfg = struct();
cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 0.25; % gliding window analysis, window size of 250ms
cfg.winstepsize   = 0.1; % steps of 100ms
cfg.latency       = [-0.55,3.25]; % to keep alignment to zero
SFC_sum.cfg = cfg;
SFC_sum.cfg.Bands = ["Beta","LowGamma","HighGamma"];
SFC_sum.cfg.conds = ["in","out"];
SFC_sum.cfg.time = -0.5:cfg.winstepsize:3.2;
% creates an error log
errorlog = fopen(fullfile(outf,[strname,'_err.txt']),'w');
% process with parpool
% test session
SFC_tempres_sorted(cfg,'R120411.mat',SFC_sum.trlinfo.trialinfo{2},SFC_sum.cfg.Bands,SFC_sum.cfg.conds,SFC_sum.freq,errorlog);
delete(gcp('nocreate'));
parpool(32);
parfor isess = 1:numel(sesses)
    try
        SFC_tempres_sorted(cfg,sesses{isess},SFC_sum.trlinfo.trialinfo{isess},SFC_sum.cfg.Bands,SFC_sum.cfg.conds,SFC_sum.freq,errorlog);
        fprintf('>>> Completed %s\n',sesses{isess});
    catch e
        fprintf(errorlog,'!!! Error with session %s: %s\n',sesses{isess},e.message);
    end
end
% load data
prog = 0.0;
fprintf('>>> Loading data %s: %3.0f%%\n',strname,prog)
for isess = 1:numel(sesses)
    sessname = sesses{isess}(1:end-4);
    load(fullfile(inf_sts,sessname),'spksum','data'); % load processed data
    % get summary for spike channels
    SFC_sum.spksums = [SFC_sum.spksums;struct2table(spksum)];
    % arrange data pairs by region
    for spkreg = ["PFC","VIP"]
        for lfpreg = ["PFC","VIP"]
            cond = strcat(spkreg,'_',lfpreg);
            SFC_sum.(cond) = [SFC_sum.(cond);struct2table(data.(cond))];
        end
    end
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,strname),'SFC_sum','-v7.3');

%%
function get_spktrgspctrm_crsschan(sess)
% compute cross-channel spike-field coupling for all sessions, both
% inter-regional and intra-regional computed
lfpf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
load(fullfile(lfpf,sess),'data_prep');% get sorted MUA spikes from all valid channels (852)
spkf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/003.MultiUnit';
dirspk = dir(fullfile(spkf,[sess,'*']));
filespk = {dirspk.name};
% get trial info
nexf = '/mnt/storage/xuanyu/MONKEY/Non-ion/spike_nexctx';
load(fullfile(nexf,sess),'nexctx');
% store root
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
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
evalc('data_all = ft_appendspike([],data_prep, spike)');

% estimate phases, non-interpolated
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
cfg_fft.spikechannel = spike.label;
cfg_fft.channel      = data_prep.label;
% spike-triggered fourier spectrogram
evalc('stsConvol = ft_spiketriggeredspectrum(cfg_fft,data_all,spike)');
stsConvol = ft_struct2single(stsConvol);
save(fullfile(outf,sess),'stsConvol','-v7.3');
fprintf('>>> Completed %s\n',sess);
end

function SFC_alltrl_sorted(cfg,sessname,trlinfosess,Bands,conds,freq,errorlog)
sessname = sessname(1:7);
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
load(fullfile(inf,sessname),'stsConvol'); % load spike-triggered spectrum phases
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat','pattern_PFC','sess'); % load PFC locations
sortf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst';
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/statSts_SFC_alltrl_sorted';
spksum = struct();
spkchans = stsConvol.label; spkPFC = cellfun(@(s) str2double(s(5:6))<9,spkchans);
spksum.session = repmat(sessname,numel(spkchans),1); spksum.spkchan = spkchans'; spksum.time = stsConvol.time'; spksum.trial = stsConvol.trial';
lfpchans = stsConvol.lfplabel; lfpPFC = cellfun(@(s) str2double(s(3:4))<9,lfpchans);
for spkreg = ["PFC","VIP"]
    switch spkreg
        case 'PFC'; spklst = spkPFC;
        case 'VIP'; spklst = ~spkPFC;
    end
    for lfpreg = ["PFC","VIP"]
        switch lfpreg
            case 'PFC'; lfplst = lfpPFC;
            case 'VIP'; lfplst = ~lfpPFC;
        end
        cond = strcat(spkreg,'_',lfpreg);
        data.(cond) = struct();
        data.(cond).session = repmat(sessname,sum(spklst)*sum(lfplst),1);
        data.(cond).spkchan = repmat(spkchans(spklst),sum(lfplst),1); data.(cond).spkchan = data.(cond).spkchan(:);
        data.(cond).lfpchan = repmat(lfpchans(lfplst),1,sum(spklst)); data.(cond).lfpchan = data.(cond).lfpchan(:);
        if strcmp(spkreg,'PFC')&&strcmp(lfpreg,'PFC') % where location is available
            pat = pattern_PFC{sess.sess_pat(cellfun(@(s) strcmp(s,sessname),sess.sess_names))};
            data.(cond).spkchan_loc = cellfun(@(s) pat{str2double(s(5:6))},data.(cond).spkchan,'uni',0);
            data.(cond).lfpchan_loc = cellfun(@(s) pat{str2double(s(3:4))},data.(cond).lfpchan,'uni',0);
            data.(cond).distance = cellfun(@(spkchan,lfpchan) sqrt(sum((spkchan-lfpchan).^2)),data.(cond).spkchan_loc,data.(cond).lfpchan_loc);
        end
        data.(cond).ppc = cell(sum(lfplst),sum(spklst));
        data.(cond).nspk = cell(sum(lfplst),sum(spklst));
        for ispk = 1:sum(spklst)
            x = find(spklst,ispk);  cfg.spikechannel = spkchans(x(end));
            load(fullfile(sortf,strcat(sessname,'-',cfg.spikechannel{1})),'SFC_brst');
            for ilfp = 1:sum(lfplst)
                y = find(lfplst,ilfp); cfg.channel = lfpchans(y(end));
                load(fullfile(brstf,sprintf('%s-AD%s',sessname,cfg.channel{1}(3:4))),'data_burst');
                lfpbadtrl = data_burst.badtrials;
                cfg.trials = trlinfosess.errorcode==0 & ~lfpbadtrl';
                data.(cond).ppc{ilfp,ispk} = nan(3,2,length(freq));
                data.(cond).nspk{ilfp,ispk} = nan(3,2,length(freq));
                for iband = 1:length(Bands)
                    for icond = conds
                        switch icond
                            case 'in'; cfg.spikesel = SFC_brst.(Bands{iband}).inlist; ix = 1;
                            case 'out'; cfg.spikesel = ~SFC_brst.(Bands{iband}).inlist; ix = 2;
                        end
                        try % if no spikes catched, discart
                            evalc('statSts = ft_spiketriggeredspectrum_stat(cfg,stsConvol);');
                            data.(cond).ppc{ilfp,ispk}(iband,ix,:) = squeeze(statSts.ppc0);
                            data.(cond).nspk{ilfp,ispk}(iband,ix,:) = squeeze(statSts.nspikes);
                        catch e
                            fprintf(errorlog,'Error catched for session %s, spike channel %s to lfp channel %s, at band %s and condition %s \n\t Error message: %s\n',sessname,cfg.spikechannel{1},cfg.channel{1},SFC_sum.cfg.Bands(iband),icond,e.message);
                        end
                    end
                end
                data.(cond).ppc{ilfp,ispk}(data.(cond).nspk{ilfp,ispk}<50) = nan;
            end
        end
        data.(cond).ppc = data.(cond).ppc(:); % reshape to align with other domains
        data.(cond).nspk = data.(cond).nspk(:); % reshape to align with other domains
    end
end
save(fullfile(outf,sessname),'spksum','data');
end

function SFC_tempres_sorted(cfg,sessname,trlinfosess,Bands,conds,freq,errorlog)
sessname = sessname(1:7);
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_unint_crsschan';
load(fullfile(inf,sessname),'stsConvol'); % load spike-triggered spectrum phases
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat','pattern_PFC','sess'); % load PFC locations
sortf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/stsconvol_brst';
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/SFC/statSts_SFC_tempres_sorted';
spksum = struct();
time = -0.5:cfg.winstepsize:3.2;
spkchans = stsConvol.label; spkPFC = cellfun(@(s) str2double(s(5:6))<9,spkchans);
spksum.session = repmat(sessname,numel(spkchans),1); spksum.spkchan = spkchans'; spksum.time = stsConvol.time'; spksum.trial = stsConvol.trial';
lfpchans = stsConvol.lfplabel; lfpPFC = cellfun(@(s) str2double(s(3:4))<9,lfpchans);
for spkreg = ["PFC","VIP"]
    switch spkreg
        case 'PFC'; spklst = spkPFC;
        case 'VIP'; spklst = ~spkPFC;
    end
    for lfpreg = ["PFC","VIP"]
        switch lfpreg
            case 'PFC'; lfplst = lfpPFC;
            case 'VIP'; lfplst = ~lfpPFC;
        end
        cond = strcat(spkreg,'_',lfpreg);
        data.(cond) = struct();
        data.(cond).session = repmat(sessname,sum(spklst)*sum(lfplst),1);
        data.(cond).spkchan = repmat(spkchans(spklst),sum(lfplst),1); data.(cond).spkchan = data.(cond).spkchan(:);
        data.(cond).lfpchan = repmat(lfpchans(lfplst),1,sum(spklst)); data.(cond).lfpchan = data.(cond).lfpchan(:);
        if strcmp(spkreg,'PFC')&&strcmp(lfpreg,'PFC') % where location is available
            pat = pattern_PFC{sess.sess_pat(cellfun(@(s) strcmp(s,sessname),sess.sess_names))};
            data.(cond).spkchan_loc = cellfun(@(s) pat{str2double(s(5:6))},data.(cond).spkchan,'uni',0);
            data.(cond).lfpchan_loc = cellfun(@(s) pat{str2double(s(3:4))},data.(cond).lfpchan,'uni',0);
            data.(cond).distance = cellfun(@(spkchan,lfpchan) sqrt(sum((spkchan-lfpchan).^2)),data.(cond).spkchan_loc,data.(cond).lfpchan_loc);
        end
        data.(cond).ppc = cell(sum(lfplst),sum(spklst));
        data.(cond).nspk = cell(sum(lfplst),sum(spklst));
        for ispk = 1:sum(spklst)
            x = find(spklst,ispk);  cfg.spikechannel = spkchans(x(end));
            load(fullfile(sortf,strcat(sessname,'-',cfg.spikechannel{1})),'SFC_brst');
            for ilfp = 1:sum(lfplst)
                y = find(lfplst,ilfp); cfg.channel = lfpchans(y(end));
                load(fullfile(brstf,sprintf('%s-AD%s',sessname,cfg.channel{1}(3:4))),'data_burst');
                lfpbadtrl = data_burst.badtrials;
                cfg.trials = trlinfosess.errorcode==0 & ~lfpbadtrl';
                data.(cond).ppc{ilfp,ispk} = nan(3,2,length(freq),length(time));
                data.(cond).nspk{ilfp,ispk} = nan(3,2,length(freq),length(time));
                for iband = 1:length(Bands)
                    for icond = conds
                        switch icond
                            case 'in'; cfg.spikesel = SFC_brst.(Bands{iband}).inlist; ix = 1;
                            case 'out'; cfg.spikesel = ~SFC_brst.(Bands{iband}).inlist; ix = 2;
                        end
                        try % if no spikes catched, discart
                            evalc('statSts = ft_spiketriggeredspectrum_stat(cfg,stsConvol);');
                            data.(cond).ppc{ilfp,ispk}(iband,ix,:,:) = squeeze(statSts.ppc0);
                            data.(cond).nspk{ilfp,ispk}(iband,ix,:,:) = squeeze(statSts.nspikes);
                        catch e
                            fprintf(errorlog,'Error catched for session %s, spike channel %s to lfp channel %s, at band %s and condition %s \n\t Error message: %s\n',sessname,cfg.spikechannel{1},cfg.channel{1},Bands(iband),icond,e.message);
                        end
                    end
                end
                data.(cond).ppc{ilfp,ispk}(data.(cond).nspk{ilfp,ispk}<50) = nan;
            end
        end
        data.(cond).ppc = data.(cond).ppc(:); % reshape to align with other domains
        data.(cond).nspk = data.(cond).nspk(:); % reshape to align with other domains
    end
end
save(fullfile(outf,sessname),'spksum','data');
end
