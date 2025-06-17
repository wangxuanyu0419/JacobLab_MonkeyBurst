function burst_wrapper(filepath, cfg);
% Wrapper for burst estimation.
% Loads raw LFP trace (ft_datatype_raw), adds times at which voltage is saturated,
% estimates power, fits bursts, and saves complete session power-stripped 
% ft_datatype_freq to disk.
%
% Input
% -----
% filepath: str
%   Path to input matfile containing time domain lfp trace.
% cfg: struct
%   saturation: double
%       Absolute voltage value at which signal is deemed saturated.
%   specest: struct
%       Configuration settings for ft_freqanalysis.
%   outputfile: str
%       Where to save the power-stripped ft_datatype_freq.

[p,n,x] = fileparts(filepath);

% load LFP, add times at which signal saturated
lfp = add_saturtimes(cfg, loadmat_singlevar(filepath));

% spectral estimation + burst estimation
pow = rmfield(addburst(cfg,ft_freqanalysis(cfg.specest, lfp)),'powspctrm');
[~,name,ext] = fileparts(filepath);
save(fullfile(cfg.savefolder,[name ext]),'pow','-v7.3');
