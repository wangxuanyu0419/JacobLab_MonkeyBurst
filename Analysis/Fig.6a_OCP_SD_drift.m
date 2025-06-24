% Compute SD drift of OCP across session time
close all
clear

% Plot session figures
win = 20; nsamp = 100;
outfigf = sprintf('/mnt/storage/xuanyu/MONKEY/Non-ion/13.PerfOCP/OCP_SD_drift/win%02d',win);
load(fullfile(outfigf,'OCP_SD'),'OCP_SD');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/13.PerfOCP/SD_drift_OCP';

%% Plot summary figure
close all
fig = figure('Position',[10 10 400 600]);
ifig = 1;
for iband = ["Beta","LowGamma","HighGamma"]
    ax = axes(fig,'Position',[0.13,0.32*ifig-0.25,0.8,0.22]);
    t = linspace(0,1,nsamp);
    plot(t,nanmean(OCP_SD.SD.(iband))*100);
    if strcmp(iband,'Beta'); xlabel('Relative time in session'); end
    ylabel('SD'); title(iband,'FontSize',15);
    ifig = ifig+1;
    box off;
    set(gca,'TickDir','out');
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'Renderer', 'painters');
print(fullfile(outfigf,'Avg_AllChan'),'-dpng');
print(fullfile(outfigf,'Avg_AllChan'),'-dpdf','-r0','-bestfit');

%% Plot by animals and region
close all
fig = figure('Position',[10 10 1600 400]);
c.Beta = 'r'; c.HighGamma = 'b';
for ianm = ["R","W"]
    anmsel = cellfun(@(s) s(1)==ianm, OCP_SD.files);
    [~,ia] = ismember(ianm,["R","W"]);
    for ireg = ["PFC","VIP"]
        regsel = cellfun(@(s) strcmp(s,ireg), OCP_SD.region);
        [~,ir] = ismember(ireg,["PFC","VIP"]);
        for iband = ["Beta","HighGamma"]
            [~,ib] = ismember(iband,["Beta","HighGamma"]);
            subplot(2,4,ia*4+ir*2-6+ib);
            t = linspace(0,1,nsamp);
            plot(t,nanmean(OCP_SD.SD.(iband)(anmsel&regsel,:))*100,'Color',c.(iband),'LineWidth',1);
            xlabel('Relative session time');
            ylabel('SD'); title(sprintf('%s %s %s',ianm,ireg,iband),'FontSize',12);
            box off;
            set(gca,'TickDir','out');
        end
    end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'Renderer', 'painters');
print(fullfile(outfigf,'Avg_AllChan_byanm'),'-dpng');
print(fullfile(outfigf,'Avg_AllChan_byanm'),'-dpdf','-r0','-bestfit');
