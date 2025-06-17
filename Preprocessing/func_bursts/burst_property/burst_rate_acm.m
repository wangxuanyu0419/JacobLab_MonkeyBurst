function [idx, a] = burst_rate_acm(brsts,trialtime)
% Computes expanded burst time indices and burst occurance for all specified bursts. This can be used for accumulation by accumarray.
% Code largely copied from "burst_width.m"
%
% Input
% -----
% brsts: table (n_bursts-by-n_var)
%   Gaussian fits to bursts, i.e. this should contain the mean and SD of fit in the temporal dimension. 
% trialtime: double
%   Trial time points of interest. Must be consistent with the times specified in brsts.
%
% Output
% ------
% idx: uint (memory width dependent on length of trialtime)
%   Index within trialtime for expanded bursts.
% a: double
%   size(idx) vector of burst count (1) corresponding to bursts in vector idx.

n_burst = height(brsts);
if n_burst == 0
    idx = [];
    a = [];
    return
end

fs = 1/unique(round(diff(trialtime), 6));

% all bursts' time expanded to fwhm 
ta = cell(n_burst,2);
for i_burst = 1:n_burst
    b = brsts{i_burst,{'t','t_sd','w'}};
    % burst times
    ta{i_burst,1} = expand_burst(b(1),b(2),fs);
    % count vector
    ta{i_burst,2} = ones(length(ta{i_burst,1}),1)*b(3);
end
ta = cell2mat(ta);

% trial time to index
[~,idx] = ismembertol(ta(:,1),trialtime);

% decrease needed memory
int_exp = ceil(log2(log2(numel(trialtime))));
if int_exp < 3
    % 2^3
    idx = uint8(idx);
elseif int_exp == 4
    % 2^4
    idx = uint16(idx);
elseif int_exp == 5
    % 2^5
    idx = uint32(idx);
else
    idx = uint64(idx);
end

a = ta(:,2);
