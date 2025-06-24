% Calculates instantaneous phases from mtmconvol and save on disk

close all
clear

inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
dif = dir(fullfile(inf,'*.mat'));
infiles = {dif.name};
expath = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Phasemap';
exdir = dir([expath '/*.mat']);
exfiles = cellfun(@(f) [f(1:7),'.mat'],{exdir(:).name},'uni',0);
exfiles = unique(exfiles);
sess = setdiff(infiles,exfiles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg              = [];
cfg.output       = 'fourier';
cfg.method       = 'mtmconvol';
cfg.channel      = 'all';
cfg.trials       = 'all';
cfg.keeptrials = 'yes';
cfg.taper        = 'hanning';
cfg.foi          = 2:128;
cfg.t_ftimwin    = 3./cfg.foi;
cfg.toi          = -1:0.001:4;
cfg.pad          = 'nextpow2';
cfg.padtype      = 'zero';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % test session
% phasemap_sess(cfg,sess{1});

% delete(gcp('nocreate'));
% parpool(3);
for isess = 1:numel(sess)
    phasemap_sess(cfg,sess{isess});
    fprintf('>>> Completed %d out of %d sessions, %.01f%%\n',isess, numel(sess), isess/numel(sess)*100);
end

%%
function phasemap_sess(cfg,sessname)
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening_inclerror';
ctxpath = '/mnt/storage/xuanyu/MONKEY/Non-ion/spike_nexctx';
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Phasemap';
load(fullfile(ctxpath,sessname),'nexctx');
load(fullfile(inf,sessname),'data_prep');
fprintf('>>> Now start %s\n',sessname);

evalc('data_phase_all = ft_freqanalysis(cfg, data_prep);');
% pass badtrial to data_freq
data_phase_all.badtrials = data_prep.badtrials;
% get trialinfo
respcode = nexctx.TrialResponseCodes(nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6);
errorcode = nexctx.TrialResponseErrors(nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6);
sample = floor(respcode/1000);
distractor = mod(floor(respcode/100),10);
test = mod(floor(respcode/10),10);
stimtype = mod(respcode,10); % standard or controlled
data_phase_all.trialinfo = table(sample,distractor,test,stimtype,errorcode);
data_phase_all = ft_struct2single(data_phase_all); % convert all values into single precision for storage space

ichan = length(data_phase_all.label);
for i = 1:ichan
    data_phase.label = data_phase_all.label{i};
    data_phase.freq = data_phase_all.freq;
    data_phase.time = data_phase_all.time;
    data_phase.cfg = data_phase_all.cfg;
    data_phase.badtrials = data_phase_all.badtrials(i,:);
    data_phase.badtrials_all = data_prep.badtrials_all(i,:);
    data_phase.sat_t_all = data_prep.sat_t_all(i,:);
    data_phase.trialinfo = data_phase_all.trialinfo;
    data_phase.phase = angle(squeeze(data_phase_all.fourierspctrm(:,i,:,:)));
    save(fullfile(outf, [sessname(1:7) '-' data_phase.label '.mat']),'data_phase','-mat');
    fprintf('/// Phase extraction done %s\n',[sessname(1:7) '-' data_phase.label]);
end
end