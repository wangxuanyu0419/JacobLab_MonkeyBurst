function gfit = fit_gaussian2candidate(candidate,z,fitopt)
    % Performs a restrained 2-pass fit of a 2D-Gaussian to a candidate region of interest.
    % Pass 1: fit SD for time and frequency
    %   Initial conditions
    %       weight: 1
    %       amplitude: candidate.amp
    %       mean time: candidate.t
    %       standard deviation time: candidate.tw/2.355 (to get width at full maximum)
    %       mean frequency: candidate.f
    %       standard deviation frequency: candidate.fw/2.355 (to get widht at full maximum)
    %       theta: 0
    %   Bounds
    %       Bounds for SDs are set at 50% to 150% of initial conditions. All other parameters are 
    %       kept constant.
    % Pass 2: fit theta
    %   Initial conditions from first pass.
    %   Bounds
    %       Theta from -45 to 45 degrees.
    %
    %
    % Input
    % -----
    % candidate: 1-by-1 struct
    %   amp: scalar double
    %       Amplitude of brightest pixel in candidate region. 
    %   f: scalar double
    %       Frequency index of brightest pixel in candidate region. 
    %   t: scalar double
    %       Time index of brightest pixel in candidate region.
    %   tw: scalar double
    %       Time dimension width of bounding box in pixels.
    %   fw: scalar double
    %       Frequency dimension width of bounding box in pixels.
    %   pidx: npix-by-1 double
    %       Pixel indices of candidate region.
    % z: 2D-double
    %   Z-scored power. frequency-by-time.
    % fitopt: optim.options.Lsqcurvefit
    %   This can be used to suppress display.
    %
    % Output
    % ------
    % gfit: table
    %   w: double
    %       weight of the GMM
    %   amp: double
    %       Amplitude of Gaussian.
    %   t: double
    %       Index of mean in time dimension.
    %   t_sd: double
    %       SD in time pixels.
    %   f: double
    %       Index of mean in frequency dimension.
    %   f_sd: double
    %       SD in frequency pixels.
    %   theta: double
    %       Rotation in radians.
    %   dof: double
    %       Degrees of freedom for fit.
    %   SSR: double
    %       Sum of squares of regression.
    %   SST: double
    %       Total sum of squares.

    if isempty(candidate)
        gfit = array2table(NaN(0, 10),'VariableNames',{'w','amp','t','t_sd','f','f_sd','theta','dof','SSR','SST'});
        return
    end

    % fit dimensions (this is more of a mnemonic for "gmm2d" inputs)
    dims.weight = 1;
    dims.amp = 2;
    dims.mu_t = 3;
    dims.sd_t = 4;
    dims.mu_f = 5;
    dims.sd_f = 6;
    dims.theta = 7;
    n_params = length(fieldnames(dims));

    %% fit
    [T,F] = meshgrid(1:size(z,2),1:size(z,1));
    m = 4; % number of fitted parameters
    px_idx = candidate.pidx;
    px_val = z(px_idx);
    % time and frequencies
    xdata = zeros(numel(px_idx), 2);
    xdata(:,1) = T(px_idx);
    xdata(:,2) = F(px_idx);
    % initial conditions
    x0 = zeros(1,n_params);
    x0(dims.weight) = 1;
    x0(dims.amp) = candidate.amp;
    x0(dims.mu_t) = candidate.t;
    x0(dims.sd_t) = candidate.tw/2.355;
    x0(dims.mu_f) = candidate.f;
    x0(dims.sd_f) = candidate.fw/2.355;
    x0(dims.theta) = 0;
    % bounds
    lb = x0;
    lb([dims.sd_t dims.sd_f]) = lb([dims.sd_t dims.sd_f])*0.5;
    ub = x0;
    ub([dims.sd_t dims.sd_f]) = ub([dims.sd_t dims.sd_f])*1.5;
    % first pass
    gfit = lsqcurvefit(@gmm2d,x0,xdata,px_val,lb,ub,fitopt);

    % second pass
    lb = gfit;
    ub = gfit;
    lb(dims.theta) = deg2rad(-45);
    ub(dims.theta) = deg2rad(45);
    gfit = lsqcurvefit(@gmm2d,gfit,xdata,px_val,lb,ub,fitopt);

    % statistics
    dof = numel(px_idx)-m; 
    z_mean = mean(px_val);
    SSR = sum((gmm2d(gfit,xdata)-z_mean).^2);
    SST = sum((px_val-z_mean).^2);
    gfit = array2table(horzcat(gfit,dof,SSR,SST),'VariableNames',{'w','amp','t','t_sd','f','f_sd','theta','dof','SSR','SST'});
