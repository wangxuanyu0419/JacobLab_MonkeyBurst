function [expanded,varargout] = expand_burst(mu,sd,fs,varargin)
% Expands Gaussian burst from centre to full width at half maximum (FWHM).
%
% Input
% -----
% mu: double (scalar)
%   1D mean of the Gaussian fit.
% sd: double (scalar)
%   1D standard deviation of the Gaussian fit.
% fs: double (scalar)
%   Sampling frequency.
% varargin{1}: double (scalar)
%   Burst frequency.
%
% Output
% ------
% expanded: double
%   1D vector of trial times when the burst was at mu +- FWHM
% varargout{1}: double
%   1D vector of size(expanded) with width of burst in trial time units
% varargout{2}: double
%   1D vector of size(expanded) with width of burst in cycles

fwhm = gauss_fwfracm(sd,1/2);
tail1 = mu:(-1/fs):(mu-fwhm/2);
tail2 = mu:(1/fs):(mu+fwhm/2);

% exclude doubled centre
expanded = horzcat(flip(tail1),tail2(2:end))';

if nargout > 1
    % vector with burst width in trial time units
    varargout{1} = ones(numel(expanded),1)*fwhm;
end
if nargout > 2 && nargin > 3
    % vector with burst width in cycles
    varargout{2} = ones(numel(expanded),1)*(fwhm*varargin{1});
end
