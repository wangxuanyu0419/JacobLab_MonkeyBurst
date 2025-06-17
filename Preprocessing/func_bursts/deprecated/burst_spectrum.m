function brstspctrm = burst_spectrum(bursts,f,t,min_cyc)
% Computes brstspctrm, an f X t sparse double matrix with non-zero values
% at the central frequencies of bursts at the time of one or more bursts.
% INPUT bursts  table containing information about fitted bursts, at least
%                   - 'fwhm_cycles': number of cycles at FWHM for temporal
%                       dimension
%                   - 'muf': center frequency
%                   - 'mut': temporal center
%                   - 'st_rot': temporal standard deviation
%       f       vector containing frequency values in Hz
%       t       vector containing trial time in s
%       min_cyc minimum number of cycles of temporal FWHM for a bursts to
%               be considered

% bursts of interest
boi = bursts.fwhm_cycles>=min_cyc & ...
        bursts.muf>=f(1) & ... 
        bursts.muf<=f(end);

% which frequency bin do the bursts' central freqs belong to
bins = discretize(bursts.muf(boi),[-Inf f(1:end-1)+diff(f)/2 Inf]);
% temporal spread of bursts within the trial
% FWHM of normal distribution is 2*sqrt(2*ln(2))*s == 2.3548*s
% need to divide it by 2 to have half width for both directions
fwhm_multi = 2*sqrt(2*log(2));
t_bursts = table2array(rowfun(@(mu,s) t>=mu-(fwhm_multi*s/2) & t<=mu+(fwhm_multi*s/2), ...
            bursts(boi,{'mut','st_rot'})));
% add all spreads per frequency
subs = [repmat(bins(:), numel(t), 1) kron(1:numel(t), ones(1,numel(bins))).'];
brstspctrm = sparse(accumarray(subs,t_bursts(:),[numel(f) numel(t)]));
