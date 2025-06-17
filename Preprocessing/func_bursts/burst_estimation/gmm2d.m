function z_data = gmm2d(x0, xdata)
% number of components
nc = numel(x0)/7;
switch ndims(xdata)
    case 2
        z_data = zeros(size(xdata,1),nc);
        x = xdata(:,1);
        y = xdata(:,2);
    case 3 
        z_data = zeros(size(xdata,1),size(xdata,2),nc);
        x = xdata(:,:,1);
        y = xdata(:,:,2);
end
for ic = 1:nc
    % Rotated 2D Gaussian
    wgt = x0((ic-1)*7+1);
    amp = x0((ic-1)*7+2);
    mu_x = x0((ic-1)*7+3);
    s_x = x0((ic-1)*7+4);
    mu_y = x0((ic-1)*7+5);
    s_y = x0((ic-1)*7+6);
    theta = x0((ic-1)*7+7);



    a = (cos(theta)^2/(2*s_x^2))+(sin(theta)^2/(2*s_y^2));
    b = -(sin(2*theta)/(4*s_x^2))+(sin(2*theta)/(4*s_y^2));
    c = (sin(theta)^2/(2*s_x^2))+(cos(theta)^2/(2*s_y^2));

    inner = -(a*(x-mu_x).^2+2*b*(x-mu_x).*(y-mu_y)+c*(y-mu_y).^2);
    z = amp*exp(inner);
    switch ndims(xdata)
        case 2
            z_data(:,ic) = wgt*z;
        case 3
            z_data(:,:,ic) = wgt*z;
    end
end
switch ndims(xdata)
    case 2
        z_data = sum(z_data,2);
    case 3
        z_data = sum(z_data,3);
end
