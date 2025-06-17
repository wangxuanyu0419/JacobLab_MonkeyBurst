function output = loadmat_singlevar(filepath)
% Loads the only variable from a matfile that contains a single variable and returns it.
%
% Input
% -----
% filepath: str
%   Path to mat file.
%
% Output
% ------
% output: (type not defined)
%   Single variable in the mat file.

% Retrieve variable names in matfile
if ~isempty(strfind(get_mat_comment(filepath), '7.3'))
    % partial loading only supported in matfile v7.3
    mat = matfile(filepath);
    vars = who(mat);
else
    mat = load(filepath);
    vars = fieldnames(mat);
end

% Check that there is only one variable in the file
if numel(vars) > 1
    error(sprintf('File %s contains more than one variable.', filepath));
else
    output = mat.(vars{1});
end
