function trialerror = numeric_to_categorical_trialerror(x)
% Convert vector of trialerror numbers in the range of 0:9 to categorical trialerrors as they are used in Cortex/Monkeylogic.
%
% Input
% -----
% x: numeric
%   Vector containing integers in the range 0:9.
% 
% Output
% ------
% trialerror: categorical
%   Categorical vector with trialerrors in Cortex/Monkeylogic format.

if ~isnumeric(x)
    error('Input argument x must be numeric.')
end
if ~all(round(x)==x)
    error('Input argument x must be integers.')
end
if ~all(ismember(x,0:9))
    error('Input argument x must be integers in range 0:9.')
end

categories = {'correct','missing','late','breakfix','nofix','early','wrong','leverbreak','ignored','aborted'};
trialerror = categorical(x,0:9,categories);
