function x = remove_non_ft_fields(x)
% Removes fields that are not in FieldTrip's definition of this filetype.

switch ft_datatype(x)
case 'raw'
    x = removefields(x,setdiff(fieldnames(x), {'time', 'trial', 'label', 'sampleinfo', 'trialinfo', 'grad', 'elec', 'opto', 'hdr', 'cfg', 'fsample'}));
otherwise
    warning('Currently only supports FT raw.')
end
