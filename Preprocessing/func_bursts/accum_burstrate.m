function mbp = accum_burstrate(bursts,trialtime,fun_burstprop)
% Computes mean burst rate across all bursts at trial times. script largely
% copied from accum_burstproperty.m
%
% Input
% -----
% bursts: cell array
%   Each cell (might represent a trial) contains a table with Gaussian fits for bursts.
% trialtime: double
%   Vector of trial times for which to compute the mean burst property.
% fun_burstprop: function handle
%   Function that takes as input one trial from 'bursts' and 'trialtime' and returns 
%   'idx', the trialtime index in integers when bursts were _active_, and 'p' the corresponding
%   burst property aligned to these indices.
%
% Output
% ------
% mbp: double
%   x-by-numel(trialtime) matrix of mean burst property

if all(cellfun(@isempty,bursts))
    mbp = NaN(size(trialtime));
    warning('No bursts passed. Returning NaN.');
    return
end
% expand bursts plus burst property
[idx, p] = cellfun(@(x) fun_burstprop(x,trialtime),bursts,'uni',0);
% concatenate trials
idx = idx(~cellfun(@isempty,idx));
p = p(~cellfun(@isempty,p(:,1)),:);
idx = cell2mat(idx);
p = cell2mat(p);
% remove burst parts outside of 'time'
p = p(idx~=0,:);
idx = idx(idx~=0);

% accumulate burst property per time point across trials
n_metric = size(p,2);
p_sum = arrayfun(@(col) accumarray(idx,p(:,col)),1:n_metric,'uni',0);
if size(p_sum{1},1) < numel(trialtime) % if no bursts at the end of trial
    for i = 1:n_metric
        p_sum{i}(end:numel(trialtime)) = NaN;
    end
end

% mean burst rate
mbp = NaN(n_metric,numel(trialtime));
for i = 1:n_metric
    mbp(i,:) = p_sum{:,i}./numel(bursts); % here divided by number of trials instead of by number of bursts
end
