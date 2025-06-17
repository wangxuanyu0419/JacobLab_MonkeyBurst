function brst_cnt = count_brst(brsts,t)
% Counts occurrences of bursts at specified times.
% 
% Input
% ----
% brsts: table
%   Gaussian fit parameters for bursts.
% t: double
%   Vector of trial times.
%
% Output
% ------
% brst_cnt: double
%   Vector of size(t) with burst count for times in t.

fs = round(1/uniquetol(diff(t)));
brst_times = cell2mat(...
    rowfun(@(mu,sd) (expand_burst(mu,sd,fs)),brsts,...
    'InputVariables',{'t','t_sd'},'OutputFormat','cell'));
% histogram bins centered on trial times (i.e. number of edges is numel(t)+1)
edges = horzcat(t, interp1(t,numel(t)+1,'linear','extrap'))-uniquetol(diff(t));
brst_cnt = histcounts(brst_times,edges)';
