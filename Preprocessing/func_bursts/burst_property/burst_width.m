function [idx, w] = burst_width(brsts,trialtime)
% Computes expanded burst time indices and burst widths for all specified bursts. This can be used for accumulation by accumarray.
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
% w: double
%   numel(trialtime)-by-2 matrix of burst widths in trialtime units (col 1) and cycles (col 2) corresponding to bursts in vector idx.

if height(brsts) == 0
    idx = [];
    w = [];
    return
end

fs = 1/unique(round(diff(trialtime), 6));

% all bursts' time expanded to fwhm and fwhm width in trial time units
tw = cell2mat(...
    rowfun(@(t,t_sd,f) expand_burst(t,t_sd,fs,f), brsts,...
    'InputVariables',{'t','t_sd','f'},'OutputFormat','cell','NumOutputs',3));
w = tw(:,2:3);

[~,idx] = ismembertol(tw(:,1),trialtime);

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
