% This function runs normalization based on already extracted spectrogram
% data.

close all
clear

Inf = '../Data/1.Preprocessing_inclerror';
Outf = '../Data/2.Normalized_inclerror';
mkdir(Outf);
Inf_dir = dir(fullfile(Inf,'*.mat'));
in_names = {Inf_dir.name};
Out_dir = dir(fullfile(Outf,'*.mat'));
fin_names = {Out_dir.name};

chan_names = setdiff(in_names,fin_names);

delete(gcp('nocreate'))
pools = parpool(32);

parfor i = 1:numel(chan_names)
    try
        norm_by_prevtrl_inclerror(chan_names{i},9,Outf);
    catch e
        fprintf('!!! Something wrong with %s \n %s \n',chan_names{i},e.message);
    end
end

%% function within loop
function norm_by_prevtrl_inclerror(f_title,n_prevtrl,Inf,Outf)
% compute z-score by normalizing to n previous trials
% for the first several trials, take all 10 leading trials
% normalization per frequency
%
% ---
% Input:
%   - f_title: name of data_freq file, e.g. 'R120410-AD01.mat'
%   - n_prevtrl: number of previous trials to estimate bandwise mean power
%   - Outf: directory to output folder

load(fullfile(Inf,f_title),'data_freq');
pow = data_freq.powspctrm;
pow_n = nan(size(pow));
ntrl = size(pow,1);
nt = length(data_freq.time);

data_norm = rmfield(data_freq,'powspctrm');
data_norm.cfg.n_prevtrl = n_prevtrl;
%% normalization
fprintf('>>> Start normalizing %s\n',f_title);
for itrl = 1:ntrl
    if itrl <= n_prevtrl
        supermat = pow(1:(n_prevtrl+1),:,:);
    else
        supermat = pow((itrl-n_prevtrl):itrl,:,:);
    end
    meanmat = repmat(squeeze(nanmean(nanmean(supermat,3)))',1,nt);
    stdmat = repmat(squeeze(nanmean(nanstd(supermat,0,3)))',1,nt);
    pow_n(itrl,:,:) = (squeeze(pow(itrl,:,:))-meanmat)./stdmat;
end
data_norm.powspctrm_norm = pow_n;

%% save normalized frequency data by channel
data_norm = ft_struct2single(data_norm);
save(fullfile(Outf, f_title),'data_norm','-mat');
fprintf('||| Normalization done: %s\n',f_title);
end