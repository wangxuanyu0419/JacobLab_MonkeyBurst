function z = z_supertrial(X,trl_to_normalise,trl_ref,dim_trl,dim_zref)
% Computes z-score across a defined dimension with reference mean and SD from multiple trials.
%
% Input
% -----
% X: numeric matrix
%   N-dimensional matrix to be z-scored.
% trl_to_normalise: numeric
%   Positive integer that specifies the trial in X to be normalised.
% trl_ref: numeric
%   Vector of positive integers that specify from which trials mean and SD will be computed.
% dim_trl: numeric
%   Positive integer that defines the trial dimension in X.
% dim_zref: numeric
%   Positive integer that defines the dimension in the supertrial across which to compute mean and SD.
%
% Output
% ------
% z: numeric matrix
%   N-dimensional matrix with the specified trial z-scored. Trial dimension is 1.   

% create supertrial
ind = repmat({':'},[1 ndims(X)]);
ind{dim_trl} = trl_ref;
supertrial = flatten2supertrial(X(ind{:}),dim_trl,dim_zref);

% do the normalisation
ind{dim_trl} = trl_to_normalise;
z = bsxfun(@rdivide,...
        bsxfun(@minus,X(ind{:}),mean(supertrial,dim_zref)),...
        std(supertrial,[],dim_zref));
