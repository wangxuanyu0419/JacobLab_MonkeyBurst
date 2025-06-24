function [fr_in,fr_out] = get_burst_cont_fr(trialinfo,epoch,band)
% This function computes average firing rate inside and outside of certain
% group of bursts. if no burst recorded in one of the conditions throughout
% all trials, a nan is returned
% 
% ---
% Input:
%   - trialinfo: ntrl x ... table, a field from data_comb, with all the
%   necessary information to compute firing rate
%   - epoch: 2 x 1 double, time window of the epoch, [s]
%   - band: 2 x 1 double, frequency range defining a band, [Hz]
% 
% ---
% Output:
%   - fr_in: average firing rate inside the bursts
%   - fr_out: average firing rate outside the bursts

ntrl = height(trialinfo);
fr_in = nan(ntrl,1);
fr_out = nan(ntrl,1);
fs = 1000;
t = epoch(1):1/fs:epoch(2); win = 20/1000;
for itrl = 1:ntrl
    brsts = trialinfo.bursts{itrl};
    brsts = brsts(brsts.t>epoch(1) & brsts.t<epoch(2) & brsts.f>band(1) & brsts.f<band(2),:);
    spks = trialinfo.multispike{itrl};
    fr = fr_est(spks,t,win);
    
    brst_t = cell2mat(arrayfun(@(mu,sd) expand_burst(mu,sd,fs),brsts.t,brsts.t_sd,'uni',0));
    brst_idc = arrayfun(@(ti) any(abs(brst_t-ti)<0.3/fs),t);
    fr_in(itrl) = mean(fr(brst_idc));
    fr_out(itrl) = mean(fr(~brst_idc));
end

fr_in = nanmean(fr_in); fr_out = nanmean(fr_out);