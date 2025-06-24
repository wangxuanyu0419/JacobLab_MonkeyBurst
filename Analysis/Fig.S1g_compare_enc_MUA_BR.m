% Get MUA encoding and compared with BR tuning for sample during the sample epoch.
clear; close all; clc;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/18.ChanCorr/Chansum.mat','ChanSum');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi/multi_mod.mat'); % contain PSTH
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/OtherProp/num_PEV','br');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs/cmp_tuning';
Tuning = ChanSum(:,[1:4,6:8,13]);
time = -1:1e-3:4; step = 20; sig_win = 100; % at least 100ms of significant encoding during sample
tds = downsample(time,step);
t_samp = [0.1,0.6];
tsel_MUA = tds>=t_samp(1) & tds<=t_samp(2);
tsel_BR = time>=t_samp(1) & time<=t_samp(2);
% get MUA tuning
MUA_chans = cellfun(@(s) sprintf('%s-AD%s.mat',s(1:7),s(13:14)), multi_mod.files,'uni',0);
Tuning.valid = ismember(Tuning.channame,MUA_chans);
Tuning.MUA_sig = cellfun(@(pev,sig) check_sig_MUA(pev,sig,tsel_MUA,sig_win/step),Tuning.PEV_S,Tuning.PEV_sig);
% load PSTH
Tuning.PSTH_S = cell(height(Tuning),1);
Tuning.PSTH_S(Tuning.valid) = multi_mod.PSTH.samp;
% sum(Tuning.MUA_sig) = 295 MUAs have significant sample tuning during SAMP
Tuning.MUA_pref = nan(height(Tuning),1);
Tuning.MUA_pref(Tuning.MUA_sig) = cellfun(@(psth) get_pref(psth,tsel_BR),Tuning.PSTH_S(Tuning.MUA_sig));
% get BR tuning
% load average BR
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/4.BurstStat/Rate_NewBand';
Bands = ["Beta","LowGamma","HighGamma"];
prog = 0.0;
fprintf('>>> Loading Data, completed %3.0f%%\n',prog)
for iband = Bands
    Tuning.(iband) = cell(height(Tuning),1);
end
for i = 1:height(Tuning)
    load(fullfile(inf,Tuning.channame{i}),'burst_rate');
    for iband = Bands
        for isamp = 1:4
            data = vertcat(burst_rate.(iband){isamp,1:4});
            Tuning.(iband){i}(isamp,:) = nanmean(data);
        end
    end
    prog = i/height(Tuning)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
% get BR pev
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_PEV/br_PEV.mat','br_PEV');
alpha = 0.05;
for iband = Bands
    Tuning.(strcat(iband,'_sig')) = br_PEV.p.(iband)<alpha; % second epoch is SAMP
end
% get BR pref
for iband = Bands
    Tuning.(strcat(iband,'_pref')) = cellfun(@(d) get_pref(d,tsel_BR),Tuning.(iband));
end
save(fullfile(outf,'Tuning'),'Tuning');

%% Plot results
close all; fig = figure('Position',[0 0 800 200]);
for ireg = ["PFC","VIP"]
    [~,ir] = ismember(ireg,["PFC","VIP"]);
    regsel = cellfun(@(s) strcmp(s,ireg),Tuning.region);
    for icond = ["MUA","HighGamma","LowGamma","Beta"]
        [~,ic] = ismember(icond,["MUA","HighGamma","LowGamma","Beta"]);
        data = Tuning.(strcat(icond,'_pref'))(Tuning.(strcat(icond,'_sig')));
        subplot(2,4,(ir-1)*4+ic);
        c = histcounts(data);
        bar(1:4,c,'FaceColor','k','EdgeColor','k','BarWidth',0.6);
        yl = ylim; ylim([yl(1), yl(2)*1.2]);
        if ir==1; title(icond); end
        if ic==1; ylabel(ireg); end
    end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outf,'cmp_tuning_MUA_Brst_SAMP_samp'),'-depsc')
print(fullfile(outf,'cmp_tuning_MUA_Brst_SAMP_samp'),'-dpng')
%% functions
function y = check_sig_MUA(pev,sig,tsel,win)
% check if there are at least t=win consecutive significant encoding
if isempty(pev); y = false; return; end
data = pev(tsel)>sig(tsel);
tgt = ones(1,win);
y = contains(char(double(data)),char(tgt));
end

function y = get_pref(data,tsel)
% get the preferred number in selected window
d = nanmean(data(:,tsel),2);
[~,y] = max(d);
end