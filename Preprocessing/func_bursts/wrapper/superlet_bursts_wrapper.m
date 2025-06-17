function superlet_bursts_wrapper(input_folder, input_file, output_folder);

lfp = load(fullfile(input_folder, input_file));
lfp = lfp.lfp;
%% compute power via superlet method and z-score
cfg = [];
cfg.specest.method = 'superlet';
cfg.specest.output = 'pow';
cfg.specest.channel = 'all';
cfg.specest.trials = 'all';
cfg.specest.keeptrials = 'yes';
cfg.specest.pad = 'nextpow2';
cfg.specest.padtype = 'zero';
cfg.specest.polyremoval = 0;
cfg.specest.foi = 4:100;
cfg.specest.toi = -1.0:0.001:3.6;
cfg.specest.superlet.basewidth = 3;
cfg.specest.superlet.combine = 'additive';
cfg.specest.superlet.order = round(linspace(1,30,numel(cfg.specest.foi)));

%% options for burst extraction
cfg.brst.min_thr = 2;
cfg.brst.step = 0.01;
cfg.brst.n_preall = 600;
if ~exist('opts','var');
    cfg.brst.opts = optimoptions('lsqcurvefit','Display','off');
end
warning('off','optimlib:lsqncommon:SwitchToLineSearch');
warning('off','MATLAB:table:RowsAddedNewVars');
cfg.brst.td = 0.001;
cfg.brst.fd = 1;

%% burst extraction
cfg.brst.outfolder_session = fullfile(output_folder, strrep(input_file,'.mat',''));
if ~exist(cfg.brst.outfolder_session,'dir')
    mkdir(cfg.brst.outfolder_session);
end
parfor itrl = 1:size(lfp.trialinfo,1)
    fprintf('trial %d \n',itrl)
    sl_brst(cfg, lfp, itrl);
end
while ~exist(fullfile(output_folder, input_file),'file')
    try
        f = dir(fullfile(cfg.brst.outfolder_session,'*.mat'));
        cfg = [];
        cfg.inputfile = arrayfun(@(x) fullfile(x.folder,x.name),f,'uni',0);
        cfg.parameter = 'trialinfo';
        cfg.appenddim = 'rpt';
        cfg.outputfile = fullfile(output_folder, input_file);
        ft_appendfreq(cfg);
    end
end
