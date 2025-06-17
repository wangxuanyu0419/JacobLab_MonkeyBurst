function data = add_saturtimes(cfg, data)
% Finds trial times when values in ft_datatype_raw are saturated and adds them to field trialinfo.
%
% Input
% -----
% cfg: struct
%   saturation: double
%       Absolute voltage value at which signal is deemed saturated.
% data: struct
%   ft_datatype_raw
%
% Output
% ------
% data: struct
%   ft_datatype_raw with variable 'raw_sat' added to field 'trialinfo'

data.trialinfo{:, 'raw_sat'} = cellfun(@(x) sparse(abs(x)>cfg.saturation)', data.trial, 'uni', 0)';
