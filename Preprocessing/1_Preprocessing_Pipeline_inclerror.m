% Perform spectral analysis and normalized by the previous 9 trials +
% current trial.
% Superlet method implemented for spectral analysis.


close all
clear

%% read in data_prep, segmented LFP functions
stdir = '../Data';
inpath = [stdir '/0.TrialScreening_inclerror'];
ctxpath = [stdir '/spike_nexctx'];
prepdir = dir([inpath '/*.mat']); % dir to all nex files
infiles = cellfun(@(f) f(1:7),{prepdir.name},'uni',0);
expath = [stdir '/1.Preprocessing_inclerror'];
exdir = dir([expath '/*.mat']);
exfiles = cellfun(@(f) f(1:7),{exdir(:).name},'uni',0);
exfiles = unique(exfiles);
mkdir(expath);

[f_name,f_list] = setdiff(infiles,exfiles);
f_path = prepdir(f_list).folder;

%% Run the Superlet spectral transformation with parallel loops on each session
cfg_prep = [];
cfg_prep.method              = 'superlet';
cfg_prep.output              = 'pow';
cfg_prep.channel             = 'all';
cfg_prep.trials              = 'all';
cfg_prep.keeptrials          = 'yes';
cfg_prep.pad                 = 'nextpow2';
cfg_prep.padtype             = 'zero';
cfg_prep.polyremoval         = 0;
cfg_prep.foi                 = 2:128; % expand more to the high gamma range
cfg_prep.toi                 = -1:0.001:4; % result padded with 1s
cfg_prep.superlet.basewidth  = 3;
cfg_prep.superlet.combine    = 'additive';
cfg_prep.superlet.order      = round(linspace(1,30,numel(cfg_prep.foi)));

delete(gcp('nocreate'))
pools = parpool(4);

parfor i = 1:numel(f_name) % do parallel processing across sessions, skip processed files
    f_title = f_name{i};
    try
        Preprocessing_Session_inclerror(cfg_prep,f_title, inpath, ctxpath, expath);
    catch e
        fprintf(2,'\nWarning\nSomething wrong with Session %s: \n%s\n',f_title,e.message);
    end
end

%% Function within the loop
function Preprocessing_Session_inclerror(cfg_prep,sess, inpath, ctxpath, outf)
% This function conduct spectral analysis for each session
% 
% ---
% Input:
%   - cfg_prep: struct, fieldtrip-style configuration for ft_freqanalysis
%   - sess: string, name of the session, e.g. 'R120415'

load(fullfile(ctxpath,[sess '.mat']),'nexctx');
load(fullfile(inpath,[sess '.mat']),'data_prep');
fprintf('>>> Now start %s\n',sess);

evalc('data_freq_all = ft_freqanalysis(cfg_prep,data_prep)');
% pass badtrial to data_freq
data_freq_all.badtrials = data_prep.badtrials;


% get trialinfo
respcode = nexctx.TrialResponseCodes(nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6);
errorcode = nexctx.TrialResponseErrors(nexctx.TrialResponseErrors==0|nexctx.TrialResponseErrors==1|nexctx.TrialResponseErrors==6);
sample = floor(respcode/1000);
distractor = mod(floor(respcode/100),10);
test = mod(floor(respcode/10),10);
stimtype = mod(respcode,10); % standard or controlled
data_freq_all.trialinfo = table(sample,distractor,test,stimtype,errorcode);

data_freq_all = ft_struct2single(data_freq_all); % convert all values into single precision for storage space
% split by channel and save the results
ichan = length(data_freq_all.label);
for i = 1:ichan
    data_freq.label = data_freq_all.label{i};
    data_freq.freq = data_freq_all.freq;
    data_freq.time = data_freq_all.time;
    data_freq.cfg = data_freq_all.cfg;
    data_freq.badtrials = data_freq_all.badtrials(i,:);
    data_freq.badtrials_all = data_prep.badtrials_all(i,:);
    data_freq.sat_t_all = data_prep.sat_t_all(i,:);
    data_freq.trialinfo = data_freq_all.trialinfo;
    data_freq.powspctrm = squeeze(data_freq_all.powspctrm(:,i,:,:));
    save(fullfile(outf, [sess '-' data_freq.label '.mat']),'data_freq','-mat');
end
fprintf('/// Spectral analysis done %s\n',sess);

end
