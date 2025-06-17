function data_burst = addburst(data_norm)
% Adds bursts into trialinfo field of FieldTrip freq data.
% Bursts are estimated as 2D Gaussian fits on the z-scored power (referenced to complete trial).
% 
% Input
% -----
% pow: struct
%   FieldTrip ft_datatype_freq struct containing the field 'powspctrm_norm'
%
% Output
% ------
% pow: struct
%   Input variable with added field 'bursts' within field 'trialinfo'

fitopt = optimoptions('lsqcurvefit','Display','off');

n_trl = size(data_norm.powspctrm_norm, 1);

data_norm.trialinfo.bursts = cell(n_trl,1);
for i_trl = 1:n_trl
    z = squeeze(data_norm.powspctrm_norm(i_trl,:,:));
    
    % find candidate regions and exclude those that are too small
    n_params = 7;
    candidates = find_burstcandidates([], z);
    exclude = arrayfun(@(x) (x.fw==1)|(x.tw==1)|(numel(x.pidx)<=n_params), candidates);
    candidates = candidates(~exclude);
    clear exclude

    % fit 2D Gaussians to candidate regions
    if ~isempty(candidates)
        gfit = cell(1,numel(candidates));
        for i_cand = 1:numel(candidates)
            gfit{i_cand} = fit_gaussian2candidate(candidates(i_cand), z, fitopt);
        end
        gfit = vertcat(gfit{:});
    else
        gfit = fit_gaussian2candidate([], z, fitopt);
    end

    % convert to Hertz and seconds
    td = 0.001;
    fd = 1;
    gfit{:,'t'} = data_norm.time(gfit{:,'t'})';
    gfit{:,'t_sd'} = gfit{:,'t_sd'}*td;
    gfit{:,'f'} = data_norm.freq(gfit{:,'f'})';
    gfit{:,'f_sd'} = gfit{:,'f_sd'}*fd;
    % theta is a bit weird

    data_norm.trialinfo.bursts{i_trl} = gfit;
    data_burst = rmfield(data_norm,'powspctrm_norm');
end
