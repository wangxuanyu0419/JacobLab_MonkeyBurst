% Plot publication figure for OCP correlation with performance
clear; close all; clc;

inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/13.PerfOCP/OCPcorrRT';
load(fullfile(inf,'OCPcorrRT_all'),'OCPcorrRT_all');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

% Plot the figure, PFC and VIP in two groups of three bars (bands)
close all
fig = figure('Position',[10 10 200 250]); hold on;
cx = [40 168 224; 248 188 61; 129 189 92]./255;
ste = @(x) std(x)/sqrt(length(x));
avg = nan(6,1); err = nan(6,1);
for ireg = ["PFC","VIP"]
    [~,ir] = ismember(ireg,["PFC","VIP"]);
    for iband = ["HighGamma","LowGamma","Beta"]
        [~,ib] = ismember(iband,["HighGamma","LowGamma","Beta"]);
        idx = ir*3+ib-3+ir-1;
        avg = mean(OCPcorrRT_all.(ireg).(iband));
        bar(idx,avg,'FaceColor',cx(ib,:),'BarWidth',0.8);
        err = ste(OCPcorrRT_all.(ireg).(iband));
        errorbar(idx,avg,err,'Color','k','CapSize',3);
    end
end
xticks([2,6]); xticklabels(["PFC","VIP"]);
ylim([-0.08,0.06])
ylabel('Corr. Coef.');
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
print(fullfile(outf,'Cmp_OCPcorrRT_region_bar'),'-dpng');
print(fullfile(outf,'Cmp_OCPcorrRT_region_bar'),'-dpdf','-r0')