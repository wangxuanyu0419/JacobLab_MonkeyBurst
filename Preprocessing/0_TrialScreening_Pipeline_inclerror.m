% Perform segmentation and trial screening. Bad trials stored to 'badtrial.m'
% Define badtrials as having data saturation between [-0.5 3]s to sample onset
% Segment data by each session and by each channel.
%
% Both correct trials and error trials are included

close all
clear
clc

%% define general variables
nexdir = dir('../Data/*.nex'); % dir to all nex files
expath = '../Data/0.TrialScreening_inclerror';
mkdir(expath);

%% preprocessing & plot error trials with problematic channels
delete(gcp('nocreate'))
pools = parpool(32);

%% Run pipeline in parallel loops for each session
parfor i = 1:numel(nexdir)
    TrialScreening_Session_inclerror(nexdir(i),expath);
    fprintf('>>> Completed %s \n',nexdir(i).name);
end


%% Function within the loop
function TrialScreening_Session_inclerror(nexdir,expath)

cfg_deftrl = [];
cfg_deftrl.trialfun = 'trialfun_inclerror';
cfg_deftrl.trialdef.eventtype = 'Strobed*'; % first 7 characters are compared
cfg_deftrl.trialdef.eventvalue = 25; % analysis starting/aligned point; reward code, 3; sample onset, 25;
cfg_deftrl.trialdef.pretrl = 1.5; % 0.5 fixation + 1s padding
cfg_deftrl.trialdef.posttrl = 1;
cfg_deftrl.trialdef.triallen = 3;
cfg_deftrl.trialdef.errorcode = [0,1,6]; % 0, correct; 1, missing; 6, mistake; nan: no-specification;
cfg_deftrl.trialdef.stimtype = nan; % nan: no-specification; 0, standard; 1, controlled;
cfg_deftrl.trialdef.sampnum = nan; % sample numerosity: 1-4; nan: no-specification;
cfg_deftrl.trialdef.distnum = nan; % distractor numerosity: 1-4; nan: no-specification;
cfg_deftrl.channel = {'AD*'};

cfg_deftrl.dataset = fullfile(nexdir.folder,nexdir.name);

% define trial
evalc('cfg_preproc = ft_definetrial(cfg_deftrl);');

% preprocess: segmentation
evalc('data_prep = ft_preprocessing(cfg_preproc);');

trng = [-0.5 3.2];
plat_thr_ms = 50;
data_prep.badtrials = get_badtrials(nexdir.name(1:7),data_prep,trng,plat_thr_ms); % step-saturation detection hard0bound.
[data_prep.badtrials_all,data_prep.sat_t_all] = get_badtrials(nexdir.name(1:7),data_prep,trng,1); % all saturation points

% store preprocessed data
save(fullfile(expath,nexdir.name(1:7)),'data_prep');
end
