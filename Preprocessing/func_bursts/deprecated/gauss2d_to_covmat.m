function sigma = gauss2d_to_covmat(sx,sy,theta)
% Computes covariance matrix sigma from bivariate sigma and rotation.
% Input sx      sigma/standard deviation for variable x
%       sy      sigma/standard deviation for variable y
%       theta   counter-clockwise rotation in rad

% scaling matrix
S = [sx 0; ...
    0 sy];
% rotation matrix
R = [cos(theta) -sin(theta); ...
    sin(theta) cos(theta)];

sigma = R*S*S*R';
