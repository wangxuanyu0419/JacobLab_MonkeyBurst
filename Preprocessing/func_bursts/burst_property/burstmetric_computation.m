function [metric, ntrl, nbrst] =  burstmetric_computation(varargin)
% Computes and accumulates a burst metric (e.g. burst rate, width)
%
% Input
% -----
%   varargin{1}==cfg: struct
%       filename: str
%           Full path to file containing Fieldtrip structure with burst information.
%       trialfilter: struct
%           trialerror: str
%               Trial error type of interest (e.g. 'correct').
%           saturation: struct
%               Settings to remove trials in which voltage was saturated.
%               time_range: double
%                   2-element vector of time interval in which to look for saturation outliers.
%               time: double
%                   Vector of trial time.
%               frac_acceptable_outliers: double
%                   Scalar in range [0 1] that sets the acceptable fraction of voltage outliers.
%                   0 is most conservative (no outliers allowed), 1 most liberal (outliers at every
%                   point in time).
%       min_cycle: double
%           Scalar that sets the threshold for temporal burst width.
%       f_bands: double
%           n-by-2 vector of frequency bin edges.
%       time: double
%           Vector of trial time.
%       fun_burstprop: function handle
%           Function to compute a burst property.
%       burst_metric_accumulator: function handle
%           Function to accumulate burst property accross trials/bursts/etc.
%       n_measures: double
%           Integer scalar of numbers of measures computed by fun_burstprop.
%   varargin{2} = filename;

% load file containing trialinfo with burst-fits
cfg = varargin{1};
if nargin == 1
    pow = loadmat_singlevar(cfg.filename);
elseif nargin == 2
    filename = varargin{2};
    pow = loadmat_singlevar(filename);
end
% select trials of interest
trloi = trialfilter(pow.trialinfo, cfg.trialfilter);
trloi = trloi & cellfun(@istable, pow.trialinfo.bursts); % exclude trials without burst computation
bursts = pow.trialinfo.bursts(trloi);

ntim = numel(pow.time);
nfrq = size(cfg.f_bands, 1);

metric = NaN(cfg.n_measures,nfrq, ntim);
ntrl = sum(trloi);
nbrst = NaN(1, nfrq);

if ntrl > 0
    for i_frq = 1:nfrq
        % select bursts by frequency and width in cycles
        brst_oi = cellfun(@(x) ...
            x(...
                x.f>=cfg.f_bands(i_frq,1) & ...
                x.f<=cfg.f_bands(i_frq,2) & ...
                ...% change this if expand to threshold
                (gauss_fwfracm(x.t_sd,1/2).*x.f)>=cfg.min_cycle,...
                :),...
            bursts, 'uni', 0);
        nbrst(i_frq) = sum(cellfun(@height,brst_oi));

        if nbrst(i_frq) > 0
            metric(:,i_frq,:) = cfg.burst_metric_accumulator(brst_oi, cfg.time, cfg.fun_burstprop);
        else % there where trials but no bursts within those trials
            metric(:,i_frq,:) = 0;
        end
    end
end
