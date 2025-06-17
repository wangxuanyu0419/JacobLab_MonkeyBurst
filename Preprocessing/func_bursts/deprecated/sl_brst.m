function sl_brst(cfg, data, itrl)
warning('off','optimlib:lsqncommon:SwitchToLineSearch');
warning('off','MATLAB:table:RowsAddedNewVars');
cfg.specest.trials = itrl;
pow = ft_freqanalysis(cfg.specest,data);
z = bsxfun(@rdivide,bsxfun(@minus,pow.powspctrm,mean(pow.powspctrm,4)),std(pow.powspctrm,[],4));
for ichan = 1:numel(pow.label)
    fprintf('channel %d \n',ichan)
    z_ch_trl = squeeze(z(:,ichan,:,:));
    %% get candidate clusters by lowering threshold
    c = multi_thr(z_ch_trl, min(z_ch_trl(:)), cfg.brst.step, cfg.brst.n_preall);
    c = c(z_ch_trl(c(:,1))>=cfg.brst.min_thr,:);
    n_clust = size(c,1);

    %% fit Gaussians to candidate bursts
    gfit = zeros(n_clust,6);
    for i_clust = 1:n_clust
        gfit(i_clust,:) = fitgauss(z_ch_trl,c(i_clust,:),cfg.brst.opts);
    end
    clear z_ch_trl
    gfit = array2table(gfit,'VariableNames',{'amplitude','mux','sx','muy','sy','theta'});

    %% get temporal width and spectral height
    % from the covariance, drop the interaction terms and use the square root to get width and height
    get_rot_s = @(sx,sy,theta) sqrt(diag(gauss2d_to_covmat(sx,sy,theta)))';
    sxsy_rot = rowfun(get_rot_s, gfit, 'InputVariables', {'sx','sy','theta'});
    gfit(:,'sx_rot') = rowfun(@(x) x(1),sxsy_rot);
    gfit(:,'sy_rot') = rowfun(@(x) x(2),sxsy_rot);
    % convert from index to time [s] and frequency [Hz]
    gfit(:,'mut') = rowfun(@(x) interp1(1:numel(pow.time),pow.time,x,'linear','extrap'), gfit(:,'mux'));
    gfit(:,'st_rot') = rowfun(@(x) x*cfg.brst.td,gfit(:,'sx_rot'));
    gfit(:,'muf') = rowfun(@(x) interp1(1:numel(pow.freq),pow.freq,x,'linear','extrap'), gfit(:,'muy'));
    gfit(:,'sf_rot') = rowfun(@(x) x*cfg.brst.fd,gfit(:,'sy_rot'));
    % FWHM for Gaussian: 2*sqrt(2*ln(2))*sigma = 2.3548
    gfit(:,'fwhm_cycles') = rowfun(@(sigma,f0) 2.3548*sigma*f0, gfit(:,{'st_rot' 'muf'}));
    gfit(:,'fwhm_Hz') = rowfun(@(sigma) 2.3548*sigma, gfit(:,{'sf_rot'}));


    pow.trialinfo{:,sprintf('bursts_%s', pow.label{ichan}(3:4))} = {gfit};
end
clear z
save(fullfile(cfg.brst.outfolder_session, sprintf('%03d.mat',itrl)), 'pow');
