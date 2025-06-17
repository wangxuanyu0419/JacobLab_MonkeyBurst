function x = roundtol(x)
% Rounds floating point numbers to tolerance. Single float to 1e-6, double float to 1e-12.
%
% Input
% -----
% x: double
%   Numbers to be rounded.
% 
% Output
% ------
% x: double
%   Numbers tolerance-rounded

switch class(x)
case 'single'
    x = round(x,6);
case 'double'
    x = round(x,12);
end
