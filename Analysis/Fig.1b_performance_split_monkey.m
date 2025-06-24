clear; close all; clc;

% Import data
f_in = "F:\Science\MonkeyData\nexctx";
dir_in = dir(fullfile(f_in,'*.mat'));
outfigf = fullfile('F:\Science\Xuanyu_MonkeyBursts\', 'data', '27.splitmonkey');

%% summarize the data
vld = [0,6,1];
trlconds = cell(size(dir_in));
trlerrors = cell(size(dir_in));
trlRT = cell(size(dir_in));
i = 1;
sessname = {dir_in.name}';
animal = cellfun(@(s) s(1), sessname);
for ifile = 1:length(sessname)
    load(fullfile(f_in,sessname{ifile}),'nexctx');
    vld_sess = ismember(nexctx.TrialResponseErrors,vld);
    ntrl = sum(vld_sess);
    trlstrs = nexctx.TrialStartInd(vld_sess);
    trlends = nexctx.TrialEndInd(vld_sess);
    trlconds{i} = nexctx.TrialResponseCodes(vld_sess);
    trlerrors{i} = nexctx.TrialResponseErrors(vld_sess);
    RT = nan(ntrl,1);
    for trl = 1:ntrl
        % correct trials
        if trlerrors{i}(trl)~=0; continue; end
        evtc_trls = nexctx.EventCodes(trlstrs(trl):trlends(trl));
        evtt_trls = nexctx.EventTimes(trlstrs(trl):trlends(trl));
        cond = num2str(trlconds{i}(trl));
        % if test==sample:
        if cond(3)==cond(1)
            RT(trl) = evtt_trls(evtc_trls==4) - evtt_trls(evtc_trls==31);
        else
            RT(trl) = evtt_trls(evtc_trls==4) - evtt_trls(evtc_trls==29);
        end
    end
    trlRT{i} = RT;
    i = i + 1;
end
bhvtable = table(sessname,animal,trlconds,trlerrors,trlRT);

%% compute group statistics
[conds, PF, RT] = cellfun(@sort_conditions, bhvtable.trlconds, bhvtable.trlerrors, bhvtable.trlRT, 'uni',0);
PF = vertcat(PF{:});
RT = vertcat(RT{:});
conds = num2str(conds{1});
cat = double(conds(:,3))-double(conds(:,1));
[~, PF_d, RT_d] = cellfun(@sort_conditions_distractors, bhvtable.trlconds, bhvtable.trlerrors, bhvtable.trlRT, 'uni',0);
PF_d = vertcat(PF_d{:});
RT_d = vertcat(RT_d{:});
[distractor, DP] = cellfun(@dprime_distractor,bhvtable.trlconds, bhvtable.trlerrors,'uni',0); 
distractor = distractor{1};
DP = vertcat(DP{:});
%% plot results for performance
close all;
fig = figure('Position',[100,100,1000,300]);
d = -3:3;
m = nan(7,1);
se = nan(7,1);
data = struct();
yx = 0.98;
% with distractor
for anm = ["R","W"]
    data.(anm) = cell(7,3);
end
i = 1;
for wd = ["Repeat","Distractor","Control"]
    subplot(1,3,i); hold on;
    for anm = ["R","W"]
        switch wd
            case "Repeat"
                dist = conds(:,2)==conds(:,1);
            case "Distractor"
                dist = (conds(:,2)~=conds(:,1)) & (conds(:,2)~='0');
            case "Control"
                dist = conds(:,2)=='0';
        end
        for di = d
            PFs = nanmean(PF(bhvtable.animal==char(anm),(cat==di)&dist),2);
            if di~=0; PFs = 1-PFs; end
            data.(anm){d==di,i} = PFs;
            m(d==di) = nanmean(PFs);
            se(d==di) = nanstd(PFs)./sqrt(size(PFs,1));
        end
    %     plot(d,m,'-o','DisplayName',anm);
        errorbar(d,m,se,'DisplayName',sprintf('%s n=%d',anm,size(PFs,1)));
    end
    % add 2-sample ttest
    for di = d
        dR = data.R{d==di,i};
        dW = data.W{d==di,i};
        [h,p,ci,stats] = ttest2(dR(~isnan(dR)),dW(~isnan(dW)));
        fprintf("%s d = %d, 2-sample ttest p = %.03f, t = %.02f, df = %d\n",wd, di, p, stats.tstat, stats.df);
        % add sig. label
        if p < 0.001
            text(di,yx,"***",'HorizontalAlignment','center');
        elseif p < 0.01
            text(di,yx,"**",'HorizontalAlignment','center');
        elseif p < 0.05
            text(di,yx,"*",'HorizontalAlignment','center');
        end
    end
    % edit figure appends
    title(wd);
    ylabel('Test judged as sample (%)');
    xlabel('Test distance to sample');
    xticks(-3:3);
    xlim([-3.5,3.5]);
    ylim([0,1]);
    set(gca,'TickDir','out');
%     set(gca,'Color','k');
    legend('boxoff');
    i = i + 1;
end
% print(fig,fullfile(outfigf,'Performance_splitanimals'),'-dpdf','-r0');
% print(fig,fullfile(outfigf,'Performance_splitanimals'),'-dpng');
%% Plot for reaction time (cat==0)
close all;
fig = figure('Position',[100,100,500,300]); hold on;
data = struct();
yx1 = 640;
yx2 = 630;
m = nan(3,2);
se = nan(3,2);
% with distractor
cases = ["Repeat","Distractor","Control"];
for anm = ["R","W"]
    data.(anm) = cell(1,3);
end
for wd = cases
    [~,i] = ismember(wd,cases);
    for anm = ["R","W"]
        [~,ianm] = ismember(anm,["R","W"]);
        switch wd
            case "Repeat"
                dist = conds(:,2)==conds(:,1);
            case "Distractor"
                dist = (conds(:,2)~=conds(:,1)) & (conds(:,2)~='0');
            case "Control"
                dist = conds(:,2)=='0';
        end
        RTs = nanmean(RT(bhvtable.animal==char(anm),(cat==0)&dist),2)*1e3; % convert s to ms
        data.(anm){i} = RTs;
        m(i,ianm) = nanmean(RTs);
        se(i,ianm) = nanstd(RTs)./sqrt(size(RTs,1));
    end
end
b = bar(m);
% Get the x-coordinates of the bars and add errorbar
x = nan(3, 2);
for k = 1:2
    x(:, k) = b(k).XEndPoints; % X positions of bars for each category
    errorbar(x(:, k), m(:, k), se(:, k), 'k', 'linestyle', 'none', 'LineWidth', 1);
end
for k = 1:3
    % 2-sample ttest
    dR = data.R{k};
    dW = data.W{k};
    [h,p,ci,stats] = ttest2(dR(~isnan(dR)),dW(~isnan(dW)));
    fprintf("%s, 2-sample ttest p = %.03f, t = %.02f, df = %d\n",cases(k), p, stats.tstat, stats.df);
    % add sig. label
    if p < 0.001
        text(k,yx1,"***",'HorizontalAlignment','center');
    elseif p < 0.01
        text(k,yx1,"**",'HorizontalAlignment','center');
    elseif p < 0.05
        text(k,yx1,"*",'HorizontalAlignment','center');
    end
    if p < 0.05
        plot(x(k,:),yx2*ones(1,2),'k','HandleVisibility','off');
    end
end
ylim([350,650]);
ylabel("RT (ms)");
yticks(400:100:600);
xticks(1:3)
xticklabels(cases);
set(gca,'TickDir','out');
legend(["R","W"],'Location','northwestoutside','Box','off');
print(fig,fullfile(outfigf,'RT_splitdistractors'),'-dpdf','-bestfit');
print(fig,fullfile(outfigf,'RT_splitdistractors'),'-dpng');
%% Plot for /deltaRT (to control)
close all;
fig = figure('Position',[100,100,500,300]); hold on;
m = nan(2,2);
se = nan(2,2);
data_diff = struct();
for anm = ["R","W"]
    data_diff.(anm) = cell(1,2);
end
yx1 = 140;
yx2 = 135;
i = 1;
cases = ["Repeat","Distractor"];
for wd = cases
    ianm = 1;
    for anm = ["R","W"]
        switch wd
            case "Repeat"
                dsel = data.(anm){1}-data.(anm){3};
            case "Distractor"
                dsel = data.(anm){2}-data.(anm){3};
        end
        data_diff.(anm){i} = dsel;
        m(i,ianm) = nanmean(dsel);
        se(i,ianm) = nanstd(dsel)./sqrt(size(dsel,1));
        ianm = ianm + 1;
    end
    i = i + 1;
end
b = bar(m);
% Get the x-coordinates of the bars and add errorbar & stats
x = nan(2, 2);
for k = 1:2
    x(:, k) = b(k).XEndPoints; % X positions of bars for each category
    errorbar(x(:, k), m(:, k), se(:, k), 'k', 'linestyle', 'none', 'LineWidth', 1);
end
for k = 1:2
    % 2-sample ttest
    dR = data_diff.R{k};
    dW = data_diff.W{k};
    [h,p,ci,stats] = ttest2(dR(~isnan(dR)),dW(~isnan(dW)));
    fprintf("%s, 2-sample ttest p = %.03f, t = %.02f, df = %d\n",cases(k), p, stats.tstat, stats.df);
    % add sig. label
    if p < 0.001
        text(k,yx1,"***",'HorizontalAlignment','center');
    elseif p < 0.01
        text(k,yx1,"**",'HorizontalAlignment','center');
    elseif p < 0.05
        text(k,yx1,"*",'HorizontalAlignment','center');
    end
    if p < 0.05
        plot(x(k,:),yx2*ones(1,2),'k','HandleVisibility','off');
    end
end
ylim([-70,150]);
ylabel("\DeltaRT (ms)")
xticks([1,2])
xticklabels(["Repeat","Distractor"]);
set(gca,'TickDir','out');
legend(["R","W"],'Location','northwestoutside','Box','off');
print(fig,fullfile(outfigf,'dRT_splitanimals'),'-dpdf','-bestfit');
print(fig,fullfile(outfigf,'dRT_splitanimals'),'-dpng');
%% D-prime by animals:
close all;
fig = figure('Position',[100,100,500,300]); hold on;
m = nan(2,3);
se = nan(2,3);
% with distractor
for anm = ["R","W"]
    data.(anm) = cell(1,3);
end
for wd = ["Repeat","Distractor","Control"]
    [~,i] = ismember(wd, ["Repeat","Distractor","Control"]);
    for anm = ["R","W"]
        [~,ianm] = ismember(anm,["R","W"]);
        DPs = DP(bhvtable.animal==char(anm),i);
        data.(anm){i} = DPs;
        m(ianm,i) = nanmean(DPs);
        se(ianm,i) = nanstd(DPs)./sqrt(size(DPs,1));
    end
end
b = bar(m);
% Get the x-coordinates of the bars and add errorbar
x = nan(2, 3);
for k = 1:3
    x(:, k) = b(k).XEndPoints; % X positions of bars for each category
    errorbar(x(:, k), m(:, k), se(:, k), 'k', 'linestyle', 'none', 'LineWidth', 1);
end
% ylim([0,1]);
ylabel("d'")
xticks([1,2])
xticklabels(["R","W"]);
set(gca,'TickDir','out');
legend(["Repeat","Distractor","Control"],'Location','northwestoutside','Box','off');
print(fig,fullfile(outfigf,'DPrime_splitanimals'),'-dpdf','-bestfit');
print(fig,fullfile(outfigf,'DPrime_splitanimals'),'-dpng');
%% D-prime by distractors:
close all;
fig = figure('Position',[100,100,500,300]); hold on;
b = bar(m');
% Get the x-coordinates of the bars and add errorbar
x = nan(3, 2);
yx1 = 3.4;
yx2 = 3.3;
cases = ["Repeat","Distractor","Control"];
for k = 1:2
    x(:, k) = b(k).XEndPoints; % X positions of bars for each category
    errorbar(x(:,k), m(k,:)', se(k,:)', 'k', 'linestyle', 'none', 'LineWidth', 1);
end
for k = 1:3
    % 2-sample ttest
    dR = data.R{k};
    dW = data.W{k};
    [h,p,ci,stats] = ttest2(dR(~isnan(dR)),dW(~isnan(dW)));
    fprintf("%s, 2-sample ttest p = %.03f, t = %.02f, df = %d\n",cases(k), p, stats.tstat, stats.df);
    % add sig. label
    if p < 0.001
        text(k,yx1,"***",'HorizontalAlignment','center');
    elseif p < 0.01
        text(k,yx1,"**",'HorizontalAlignment','center');
    elseif p < 0.05
        text(k,yx1,"*",'HorizontalAlignment','center');
    end
    if p < 0.05
        plot(x(k,:),yx2*ones(1,2),'k','HandleVisibility','off');
    end
end
% ylim([0,1]);
ylabel("d'")
xticks([1,2,3])
xticklabels(["Repeat","Distractor","Control"]);
set(gca,'TickDir','out');
legend(["R","W"],'Location','northwestoutside','Box','off');
print(fig,fullfile(outfigf,'DPrime_splitdistractors'),'-dpdf','-bestfit');
print(fig,fullfile(outfigf,'DPrime_splitdistractors'),'-dpng');
%% Print overall statistics (PF) split by animal and distractor type
m = nan(2,3);
se = nan(2,3);
% with distractor
for anm = ["R","W"]
    data.(anm) = cell(1,3);
end
for wd = ["Repeat","Distractor","Control"]
    [~,i] = ismember(wd, ["Repeat","Distractor","Control"]);
    for anm = ["R","W"]
        [~,ianm] = ismember(anm,["R","W"]);
        PFs = PF_d(bhvtable.animal==char(anm),i);
        data.(anm){i} = PFs;
        m(ianm,i) = nanmean(PFs);
        se(ianm,i) = nanstd(PFs)./sqrt(size(PFs,1));
        fprintf("Accuracy of Monkey %s in %s trials: %d %% +- %.01f %%\n",anm, wd, round(m(ianm,i)*100), se(ianm,i)*100);
    end
    % Wilconxon rank-sum test
    fprintf("Ranksum test for %s trials: p = %.03f\n",wd, ranksum(data.R{i},data.W{i}));
end

%% functions
function [conds, PF, RT] = sort_conditions(trlconds, trlerrors, trlRT)
% this function returns the list of indexs for each condition specified in
% `conds`.
conds = nan(160,1);
PF = nan(1,160);
RT = nan(1,160);
i = 1;
for sample = 1:4
    for distractor = 0:4
        for test = 1:4
            for ctrl = 0:1
                conds(i) = sample*1e3 + distractor*1e2 + test*10 + ctrl;
                trls = trlconds==conds(i);
                errors = trlerrors(trls)==0;
                PF(i) = mean(errors);
                RTx = trlRT(trls);
                RT(i) = mean(RTx(errors));
                i = i+1;
            end
        end
    end
end
end

function [distractor,dprime] = dprime_distractor(trlconds, trlerrors)
% this function returns the d-prime for each distractor type
dprime = nan(1,3);
distractor = ["Repeat","Distractor","Control"];
conds = num2str(trlconds);
match = conds(:,3)==conds(:,1);
for d = distractor
    switch d
        case "Repeat"
            dist = conds(:,2)==conds(:,1);
        case "Distractor"
            dist = (conds(:,2)~=conds(:,1)) & (conds(:,2)~='0');
        case "Control"
            dist = conds(:,2)=='0';
    end
    hit(distractor==d) = sum(trlerrors==0 & dist & match); % correct response in match trials.
    miss(distractor==d) = sum(trlerrors==1 & dist & match); % missing the match trials
    false_alarm(distractor==d) = sum(trlerrors==6 & dist); % error (6) only in non-match trials.
    correct_rejection(distractor==d) = sum(trlerrors==0 & dist & ~match); % correct response in non-match trials.
end
H = hit ./ (hit + miss);
F = false_alarm ./ (false_alarm + correct_rejection);

% Adjust for extreme values
for d = distractor
    i = find(distractor==d);
    if H(i) == 1
        H(i) = 1 - 1./(2.*(hit(i) + miss(i)));
    elseif H(i) == 0
        H(i) = 1./(2.*(hit(i) + miss(i)));
    end

    if F(i) == 0
        F(i) = 1./(2.*(false_alarm(i) + correct_rejection(i)));
    elseif F(i) == 1
        F(i) = 1 - 1./(2.*(false_alarm(i) + correct_rejection(i)));
    end
end

% Compute z-scores for H and F
zH = norminv(H); % Z-transform of hit rate
zF = norminv(F); % Z-transform of false alarm rate

dprime = zH - zF;
end

function [distractor, PF, RT] = sort_conditions_distractors(trlconds, trlerrors, trlRT)
% this function returns the list of indexs for each condition specified in
% `conds`.
distractor = ["Repeat","Distractor","Control"];
PF = nan(1,length(distractor));
RT = nan(1,length(distractor));
conds = num2str(trlconds);
match = conds(:,3)==conds(:,1);
for d = distractor
    [~,i] = ismember(d,distractor);
    switch d
        case "Repeat"
            dist = conds(:,2)==conds(:,1);
        case "Distractor"
            dist = (conds(:,2)~=conds(:,1)) & (conds(:,2)~='0');
        case "Control"
            dist = conds(:,2)=='0';
    end
    errors = trlerrors(dist)==0;
    PF(i) = mean(errors);
    RTx = trlRT(dist);
    RT(i) = mean(RTx(errors));
end
end