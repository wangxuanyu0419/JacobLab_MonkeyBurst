% compute and plot granger causality with PFC-VIP connectivity,
% separate by cluster.
clear; close all; clc;
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/24.ERP/0.TrialScreening_inclerror';
dirf = dir(fullfile(inf,'*.mat')); sesses = {dirf.name};
delete(gcp("nocreate")); parpool(32);
parfor isess = 1:numel(sesses)
    get_sess_granger(sesses{isess});
    fprintf('>>> Completed %s\n',sesses{isess});
end
%% get summary
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat';
load(fullfile(inf,'T'),'T');
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';
load(fullfile(inf,'AvgBrstSpatial'),'AvgBrstSpatial');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/26.connectivity';
grgf = '/mnt/storage/xuanyu/MONKEY/Non-ion/26.connectivity/sess_grg_ts';
load(fullfile(outf,'con_sum'),'con_sum');
con_sum.grg_ts = cell(height(con_sum),1);
prog = 0.0; fprintf('>>> Loading data: %3.0f%%\n',prog);
for isess = 1:numel(sesses)
    % load granger matrix
    load(fullfile(grgf,sesses{isess}),'coherence');
    con_sum.grg_ts{isess} = coherence.grangerspctrm;
    prog = isess/numel(sesses)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
freq = coherence.freq;
time = coherence.time;
save(fullfile(outf,'con_sum'),'con_sum','freq_psi');
%% functions
function get_sess_granger(sess)
% linearly defined bands, multi-taper approach, powerline-noise removed.
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/24.ERP/0.TrialScreening_inclerror';
load(fullfile(inf,sess),'data_prep');
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/26.connectivity/sess_grg_ts';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add notch filter
cfg            = [];
cfg.dftfilter   = 'yes';
evalc('data = ft_preprocessing(cfg,data_prep);');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSI, time-resolved
timwin        = 0.5; % gliding window analysis, window size of 500ms
winstepsize   = 0.25; % steps of 250ms
time = -0.5:winstepsize:3.75;
for it = 1:length(time)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % choose data by time window
    cfg            = [];
    cfg.latency    = time(it)+timwin/2*[-1,1]; % take certain window
    evalc("dsel = ft_selectdata(cfg,rmfield(data_prep,{'badtrials','badtrials_all','ERP','trialinfo','sat_t_all'}));");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use parametric way of frequency transformation (fourier)
    cfg            = [];
    cfg.output     = 'fourier';
    cfg.method     = 'mtmfft';
    cfg.trials     = data_prep.trialinfo.errorcode==0; % only correct trials.
    cfg.foilim     = [0 128];
    cfg.tapsmofrq  = 2; % smooth window along frequency axis
    cfg.keeptrials = 'yes';
    cfg.channel    = 'all';
    cfg.pad        = 'nextpow2';
    evalc('freq = ft_freqanalysis(cfg, dsel);');
    cfg = [];
    cfg.method = 'granger';
    evalc('coh = ft_connectivityanalysis(cfg, freq);');
    if it==1; coherence = coh;
    else; coherence.grangerspctrm = cat(4,coherence.grangerspctrm,coh.grangerspctrm); end
end
coherence.time = time;
save(fullfile(outf,sess),'coherence');
end