function supertrial = flatten2supertrial(y,dim_trial,dim_append)
% Appends a dimension along another dimension and thus flattens the resulting matrix.
% Can be used to concatenate individual trials to a 'supertrial'.
%
% Input
% -----
% y: numeric matrix
%   N-dimensional matrix to be flattened.
% dim_trial: numeric
%   Integer that defines the trial dimension in y.
% dim_append: numeric
%   Integer that defines dimension along which to append individial trials.
%
% Output
% ------
% supertrial: numeric matrix
%   N-dimensional matrix in which the trial dimension was appended to to the append dimension.
%   dim_trial in this matrix is 1.

% put trial dimension behind append dimension
dimorder = setdiff(1:ndims(y), dim_trial);
ix_da = find(dimorder==dim_append);
dimorder = [dimorder(1:ix_da) dim_trial dimorder(ix_da+1:end)];
% define the reshape size
sz = size(y);
rsh_sz = sz(dimorder);
rsh_sz(dimorder==dim_append) = sz(dim_append)*sz(dim_trial);
rsh_sz(dimorder==dim_trial) = 1;

supertrial = reshape(permute(y,dimorder), rsh_sz);
% reverse permutation so that we get the same dimension order as the input
dimorder_t(dimorder) = 1:length(dimorder);
supertrial = permute(supertrial,dimorder_t);
