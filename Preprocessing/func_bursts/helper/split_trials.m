function out = split_trials(data)
% Splits trials of a FieldTrip structure using ft_selectdata.
cfg = [];
n_trl = height(data.trialinfo);
out = cell(n_trl,1);
for i_trl = 1:n_trl
    cfg.trials = i_trl;
    out{i_trl} = ft_selectdata(cfg, data);
end
