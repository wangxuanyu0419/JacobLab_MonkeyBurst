% estimate bursts from normalized powerspectra data

close all
clear

%% compare input files and exist output files
inf = dir(fullfile('../Data/2.Normalized_inclerror','*.mat'));
outfolder = fullfile('../3.Bursts_inclerror','with_sat'); % firstly, saturation points were kept
mkdir(outfolder);
outf = dir(fullfile(outfolder,'*.mat'));
[f_name,f_list] = setdiff({inf.name},{outf.name});
f_path = inf(f_list).folder;

%% burst extraction
delete(gcp('nocreate'))
pools = parpool(32);

parfor i = 1:numel(f_name)
    f_file = f_name{i};
    f_title = f_file(1:end-4);
    try
        burst_extraction(f_path,f_name{i},outfolder);
    catch e
        fprintf('\nWarning: Something wrong with Session %s: \n%s\n',f_title,e.message);
    end
end

%% clear saturated bursts
inf = outfolder;
outf = '../Data/3.Bursts_inclerror/no_sat';
mkdir(outf);
Inf_dir = dir(fullfile(inf,'*.mat'));
Outf_dir = dir(fullfile(outf,'*.mat'));
Inf_files = {Inf_dir.name};
Outf_files = {Outf_dir.name};
chan_names = setdiff(Inf_files,Outf_files);

delete(gcp('nocreate'))
pools = parpool(32);

parfor i = 1:numel(chan_names)
    try
        burst_clear_sat_inclerror(chan_names{i}, inf, outf);
        fprintf('>>> Completed %s\n',chan_names{i});
    catch e
        fprintf('\nWarning: Something wrong with Session %s: \n%s\n',f_title,e.message);
    end
end

%% filter by width
cyc_thr = 1;

inf = outf;
outf = sprintf('../Data/3.Bursts_inclerror/no_sat_%dcyc',cyc_thr);
mkdir(outf);
Inf_dir = dir(fullfile(inf,'*.mat'));
Outf_dir = dir(fullfile(outf,'*.mat'));
Inf_files = {Inf_dir.name};
Outf_files = {Outf_dir.name};
sess_names = setdiff(Inf_files,Outf_files);

delete(gcp('nocreate'))
pools = parpool(32);

parfor i = 1:numel(sess_names)
    burst_screen_width_inclerror(sess_names{i},cyc_thr,inf,outf);
    fprintf('>>> Completed %s\n',sess_names{i});
end

%% functions within loop
function burst_extraction(f_path,f_name,outpath)
    f_title = f_name(1:end-4);
    load(fullfile(f_path,f_name));
    fprintf('Now start: %s\n',f_title);
    
    data_burst = addburst(data_norm); % in `./func_bursts/burst_estimation`
    fprintf('Burst extraction done: %s\n',f_title);

    save(fullfile(outpath,[f_title '.mat']),'data_burst','-mat');
    fprintf('Save file done: %s\n',f_title);
end

function burst_clear_sat_inclerror(filename, Inf, Outf)
% This function clear bursts with saturation points in the data_burst files
%   -   saturation within half width gaussian window is excluded

load(fullfile(Inf,filename),'data_burst');

ntrl = size(data_burst.trialinfo,1);
burst_clear = cell(ntrl,1);

sum_sat = nan(ntrl,1);
for itrl = 1:ntrl
    b = data_burst.trialinfo.bursts{itrl};
    sat = data_burst.sat_t_all{itrl};
    fwhm = arrayfun(@(sd) gauss_fwfracm(sd,0.5),b.t_sd);
    issat = arrayfun(@(ib) any(sat>(b.t(ib)-fwhm(ib))&sat<(b.t(ib)+fwhm(ib))),1:height(b));
    sum_sat(itrl) = sum(issat);
    burst_clear{itrl} = b(~issat,:);
end
data_burst.trialinfo.bursts = burst_clear;
data_burst.badtrials_satbrst = sum_sat;
fprintf('!!! %d saturating trials, %d saturating burst excluded\n',sum(data_burst.badtrials_all),sum(sum_sat));

save(fullfile(Outf,filename),'data_burst');

function burst_screen_width_inclerror(filename,cyc_thr,Inf,Outf)
% This function clear bursts with short life span
%   -   saturation within half width gaussian window is excluded

load(fullfile(Inf,filename),'data_burst');

ntrl = size(data_burst.trialinfo,1);
burst_clear = cell(ntrl,1);
for itrl = 1:ntrl
    b = data_burst.trialinfo.bursts{itrl};
    fwhm = gauss_fwfracm(b.t_sd,0.5); tcyc = 1./b.f;
    burst_clear{itrl} = b(fwhm>(tcyc.*cyc_thr),:);
end
data_burst.trialinfo.bursts = burst_clear;

save(fullfile(Outf,filename),'data_burst');