function fw = gauss_fwfracm(sd,frac)
% returns the full width at frac maximum of a Gaussian
% e.g. for half maximum of standard normal distribution:
% fwhm = gauss_fwfracm()1,1/2)
fw = 2*sqrt(2*log(1/frac))*sd;
