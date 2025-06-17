function z_data = gauss2d(x0, xdata)
% Rotated 2D Gaussian
amp = x0(1);
mu_x = x0(2);
s_x = x0(3);
mu_y = x0(4);
s_y = x0(5);
theta = -x0(6)/180*pi;
switch ndims(xdata)
    case 2
        x = xdata(:,1);
        y = xdata(:,2);
    case 3 
        x = xdata(:,:,1);
        y = xdata(:,:,2);
end

% xm      = (x-mu_x)*cos(theta) - (y-mu_y)*sin(theta);
% ym      = (x-mu_x)*sin(theta) + (y-mu_y)*cos(theta);
% u       = (xm/s_x).^2 + (ym/s_y).^2;
% z_data     = amp*exp(-u/2);

a = (cos(theta)^2/(2*s_x^2))+(sin(theta)^2/(2*s_y^2));
b = -(sin(2*theta)/(4*s_x^2))+(sin(2*theta)/(4*s_y^2));
c = (sin(theta)^2/(2*s_x^2))+(cos(theta)^2/(2*s_y^2));

inner = -(a*(x-mu_x).^2+2*b*(x-mu_x).*(y-mu_y)+c*(y-mu_y).^2);
z_data = amp*exp(inner);
