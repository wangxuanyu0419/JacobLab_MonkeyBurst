function gfit = fitgauss(z,c,opts)
% Fits 2D Gaussian to candidate bursts
% Input z       z-scored power
%       c       candidate cluster properties
%               c(1)  linear index in z of brightest pixel 
%               c(2)  threshold at which cluster appeared first
%               c(3)  lowest threshold before merge
%               c(4)  x index of bounding box left edge
%               c(5)  y index of bounding box top edge
%               c(6)  bounding box x-width in bins
%               c(7)  bounding box y-height in bins
%       opts    options for lsqcurvefit
% Output    gfit    2D Gaussian with properties
%               gfit(1) amplitude
%               gfit(2) center for x (mux)
%               gfit(3) sigma for x (sx)
%               gfit(4) center for y (muy)
%               gfit(5) sigma for y (sx)
%               gfit(6) theta/rotation in rad
    
    % time and frequency axes in bins
    t = round(c(4)):round(c(4)+c(6)-1);
    f = round(c(5)):round(c(5)+c(7)-1);

    [T,F] = meshgrid(t,f);
    xdata = zeros([size(T) 2]);
    xdata(:,:,1) = T;
    xdata(:,:,2) = F;

    [mu_f, mu_t] = ind2sub(size(z), c(1));
    % [amplitude mu_t s_t mu_f s_f theta]
    x0 = [z(c(1)) mu_t numel(t)/2 mu_f numel(f)/2 0];
    lb = [z(c(1)) mu_t 1 mu_f 1 deg2rad(-45)];
    ub = [z(c(1)) mu_t Inf mu_f Inf deg2rad(45)];

    gm = @(x0,xdata) gauss2d(x0,xdata);
    try
        gfit = lsqcurvefit(gm,x0,xdata,z(f,t),lb,ub,opts);
    catch
        % bounds might be illegal
        gfit = lsqcurvefit(gm,x0,xdata,z(f,t),[],[],opts);
    end
end
