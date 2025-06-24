% This function is based on extract_multiunit_pipeline, computing multiunit
% spiking from .plx of each session, plot the reference figure

close all
clear

sesslist = dir('/mnt/storage/xuanyu/MONKEY/Non-ion/0.TrialScreening/*.mat');
sess_names = {sesslist.name};
sess_names = cellfun(@(s) s(1:7),sess_names,'uni',0);

delete(gcp('nocreate'))
pools = parpool(12);

parfor i = 1:numel(sess_names)
    arrayfun(@(iChan) extract_multiunit(sess_names{i},iChan),1:16);
end

%% switch different percentiles to plot - abandoned
% sesslist = dir('/mnt/storage2/xuanyu/MONKEY/Non-ion/8.SpikeSorting/*.mat');
% sess_names = {sesslist.name};
% logf = '/mnt/storage2/xuanyu/MONKEY/Non-ion/8.SpikeSorting/000.Percentile';
% try
%     load(fullfile(logf,'performancelog.mat'),'perflog');
% catch % initiate perflog
%     perflog = struct();
%     perflog.sess_names = sess_names;
%     perflog.completed = false(size(sess_names));
%     save(fullfile(logf,'performancelog.mat'),'perflog');
% end
% completed = perflog.completed;
% sess_todo = find(~completed);
%
% perc = 5:10:95;
%
% delete(gcp('nocreate'))
% pools = parpool(length(perc));
%
% for i = 1:numel(sess_todo)
%     sess_sel = sess_names{sess_todo(i)};
%     parfor ip = 1:length(perc)
%         switch_percentile(sess_sel,perc(ip));
%     end
%     performancelog(sess_todo(i),logf);
% end

%% plot amplitude histogram for each session
sesslist = dir('/mnt/storage2/xuanyu/MONKEY/Non-ion/0.TrialScreening/*.mat');
sess_names = {sesslist.name};

delete(gcp('nocreate'))
pools = parpool(20);

parfor i = 1:numel(sess_names)
    sess_sel = sess_names{i}(1:7);
%     sess_amp_histogram(sess_sel);
%     sess_amp_histfit(sess_sel,'n+1');
    sess_amp_histfit(sess_sel,'bestfit');
    fprintf('>>> Completed %s\n',sess_sel);
end

%% rethreshold based on gaussianfit
clear
close all
gausf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/001.GaussianFit_bestfit';
sesslist = dir(fullfile(gausf,'*.mat'));
sess_names = {sesslist.name};
logf = '/mnt/storage/xuanyu/MONKEY/Non-ion/8.SpikeSorting/002.Rethr_bestfit';

try
    load(fullfile(logf,'performancelog.mat'),'perflog');
catch % initiate perflog
    perflog = struct();
    perflog.sess_names = sess_names;
    perflog.completed = false(size(sess_names));
    save(fullfile(logf,'performancelog.mat'),'perflog');
end
completed = perflog.completed;
sess_todo = find(~completed);

c = 1.96; % change this parameter for several times of SD away; cut at 95% one-tailed CI
outfigf = fullfile(logf,sprintf('mu+%.01fsigma',c));
try
    mkdir(outfigf)
catch
end

delete(gcp('nocreate'))
pools = parpool(16);

for i = 1:numel(sess_todo)
    sess_sel = sess_names{sess_todo(i)};
    load(fullfile(gausf,sess_sel),'gaus_fit');
    parfor ichan = 1:numel(gaus_fit.Chan)
        if ~isempty(gaus_fit.GMM{ichan}) % skip discarded channel
            [mu,ik] = min(gaus_fit.GMM{ichan}.mu);
            sd = sqrt(gaus_fit.GMM{ichan}.Sigma(ik));
            rethreshold(outfigf,sess_sel(1:7),ichan,mu+sd*c);
        end
    end
    performancelog(sess_todo(i),logf);
end