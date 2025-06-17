% Plot Average Burst-prob. for each band, region and monkey
clear; close all; clc
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand/data_sum.mat','data_sum');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

%% Compute grandavg on all valid channels
% now only distractor trials taken
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),data_sum.Region);
anm_R_idx = cellfun(@(s) strcmp(s(1),'R'),data_sum.files);
cband = {'b','r','g'};
Bands = ["Beta","LowGamma","HighGamma"]; yrng = {[15 35], [35 60], [60 90]};
gaus_win = 150;
tlim = [-0.5,3.2]; time = data_sum.time;
trng = time>=tlim(1) & time<=tlim(2); time_sel = time(trng);
grey = ones(1,3).*0.5;

close all
fig = figure('Position',[50 50 1280 400], 'Visible', true);

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.1; reg_list = PFC_idx;
        case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx;
    end
    y0 = 0.12;
    ax = axes(fig,'Position', [x0, y0, 0.37 0.76]); % figure window
    hold on;
    
    fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    ib = 0;
    for iband = Bands
        ib = ib+1;
        data_sel = data_sum.(iband)(reg_list,trng);
        data_avg = nanmean(data_sel);
        data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
        data_avg = smoothdata(data_avg,'gaussian',gaus_win);
        data_ste = smoothdata(data_ste,'gaussian',gaus_win);
        data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
        
        fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
        plot(time_sel,data_avg,'Color',cband{ib},'LineWidth',1.5,'DisplayName',iband);
        xlim(tlim); ylim([0.08,0.3]);
        xlabel('Time from Sample Onset [s]','FontSize',12);
        ylabel('Average Burst Probability','FontSize',12);
        legend('boxoff')
        title(ax,sprintf('%s, n = %d',ireg,sum(reg_list)),'FontSize',20);
    end
end

set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'GrandAvg_BR_region'),'-depsc')
print(fullfile(outfigf,'GrandAvg_BR_region'),'-dpng')

%% Compute grandavg of no-distractor trials on all valid channels
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),data_sum.Region);
anm_R_idx = cellfun(@(s) strcmp(s(1),'R'),data_sum.files);
cband = {'b','r','g'};
Bands = ["Beta","LowGamma","HighGamma"]; yrng = {[15 35], [35 60], [60 90]};
gaus_win = 150;
tlim = [-0.5,3.2]; time = data_sum.time;
trng = time>=tlim(1) & time<=tlim(2); time_sel = time(trng);
grey = ones(1,3).*0.5;

close all
fig = figure('Position',[50 50 1280 400], 'Visible', true);

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.1; reg_list = PFC_idx;
        case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx;
    end
    y0 = 0.12;
    ax = axes(fig,'Position', [x0, y0, 0.37 0.76]); % figure window
    hold on;
    
    fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
    ib = 0;
    for iband = Bands
        ib = ib+1;
        data_sel = data_sum.nodist.(iband)(reg_list,trng);
        data_avg = nanmean(data_sel);
        data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
        data_avg = smoothdata(data_avg,'gaussian',gaus_win);
        data_ste = smoothdata(data_ste,'gaussian',gaus_win);
        data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
        
        fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
        plot(time_sel,data_avg,'Color',cband{ib},'LineWidth',1.5,'DisplayName',iband);
        xlim(tlim); ylim([0.08,0.3]);
        xlabel('Time from Sample Onset [s]','FontSize',12);
        ylabel('Average Burst Probability','FontSize',12);
        legend('boxoff')
        title(ax,sprintf('%s, n = %d',ireg,sum(reg_list)),'FontSize',20);
    end
end

set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'GrandAvg_BR_region_nodist'),'-depsc')
print(fullfile(outfigf,'GrandAvg_BR_region_nodist'),'-dpng')


%% Compute grandavg of distractor trials, separate by animals
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),data_sum.Region);
cband = {'b','r','g'};
Bands = ["Beta","LowGamma","HighGamma"]; yrng = {[15 35], [35 60], [60 90]};
gaus_win = 150;
tlim = [-0.5,3.2]; time = data_sum.time;
trng = time>=tlim(1) & time<=tlim(2); time_sel = time(trng);
grey = ones(1,3).*0.5;

close all
fig = figure('Position',[50 50 1280 800], 'Visible', true);

for ianm = ["R","W"]
    anm_sel = cellfun(@(s) strcmp(s(1),ianm),data_sum.files);
    switch ianm
        case 'R'; y0 = 0.57;
        case 'W'; y0 = 0.1;
    end
    for ireg = ["PFC","VIP"]
        switch ireg
            case 'PFC'; x0 = 0.12; reg_list = PFC_idx & anm_sel;
            case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx & anm_sel;
        end
        ax = axes(fig,'Position', [x0, y0, 0.37 0.34]); % figure window
        hold on;
        
        fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        ib = 0;
        for iband = Bands
            ib = ib+1;
            data_sel = data_sum.(iband)(reg_list,trng);
            data_avg = nanmean(data_sel);
            data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
            data_avg = smoothdata(data_avg,'gaussian',gaus_win);
            data_ste = smoothdata(data_ste,'gaussian',gaus_win);
            data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
            
            fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            plot(time_sel,data_avg,'Color',cband{ib},'LineWidth',1.5,'DisplayName',iband);
            xlim(tlim); ylim([0.05,0.3]);
            xlabel('Time from Sample Onset [s]','FontSize',12);
            ylabel('Average Burst Probability','FontSize',12);
            legend('boxoff')
            title(ax,sprintf('Monkey %s %s, n = %d',ianm,ireg,sum(reg_list)),'FontSize',20);
        end
    end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'GrandAvg_BR_region_anm'),'-dpdf','-r0','-bestfit')
print(fullfile(outfigf,'GrandAvg_BR_region_anm'),'-dpng')

%% Compute grandavg of no-distractor trials, separate by animals
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),data_sum.Region);
cband = {'b','r','g'};
Bands = ["Beta","LowGamma","HighGamma"]; yrng = {[15 35], [35 60], [60 90]};
gaus_win = 150;
tlim = [-0.5,3.2]; time = data_sum.time;
trng = time>=tlim(1) & time<=tlim(2); time_sel = time(trng);
grey = ones(1,3).*0.5;

close all
fig = figure('Position',[50 50 1280 800], 'Visible', true);

for ianm = ["R","W"]
    anm_sel = cellfun(@(s) strcmp(s(1),ianm),data_sum.files);
    switch ianm
        case 'R'; y0 = 0.57;
        case 'W'; y0 = 0.1;
    end
    for ireg = ["PFC","VIP"]
        switch ireg
            case 'PFC'; x0 = 0.12; reg_list = PFC_idx & anm_sel;
            case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx & anm_sel;
        end
        ax = axes(fig,'Position', [x0, y0, 0.37 0.34]); % figure window
        hold on;
        
        fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        ib = 0;
        for iband = Bands
            ib = ib+1;
            data_sel = data_sum.nodist.(iband)(reg_list,trng);
            data_avg = nanmean(data_sel);
            data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
            data_avg = smoothdata(data_avg,'gaussian',gaus_win);
            data_ste = smoothdata(data_ste,'gaussian',gaus_win);
            data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
            
            fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            plot(time_sel,data_avg,'Color',cband{ib},'LineWidth',1.5,'DisplayName',iband);
            xlim(tlim); ylim([0.05,0.3]);
            xlabel('Time from Sample Onset [s]','FontSize',12);
            ylabel('Average Burst Probability','FontSize',12);
            legend('boxoff')
            title(ax,sprintf('Monkey %s %s, n = %d',ianm,ireg,sum(reg_list)),'FontSize',20);
        end
    end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'GrandAvg_BR_region_nodist_anm'),'-depsc')
print(fullfile(outfigf,'GrandAvg_BR_region_nodist_anm'),'-dpng')

%% Distractor induced changes
PFC_idx = cellfun(@(s) strcmp(s,'PFC'),data_sum.Region);
cband = {'b','r','g'};
Bands = ["Beta","LowGamma","HighGamma"]; yrng = {[15 35], [35 60], [60 90]};
gaus_win = 150;
tlim = [-0.5,3.2]; time = data_sum.time;
trng = time>=tlim(1) & time<=tlim(2); time_sel = time(trng);
grey = ones(1,3).*0.5;

close all
fig = figure('Position',[50 50 1280 800], 'Visible', true);

for ianm = ["R","W"]
    anm_sel = cellfun(@(s) strcmp(s(1),ianm),data_sum.files);
    switch ianm
        case 'R'; y0 = 0.57;
        case 'W'; y0 = 0.1;
    end
    for ireg = ["PFC","VIP"]
        switch ireg
            case 'PFC'; x0 = 0.12; reg_list = PFC_idx & anm_sel;
            case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx & anm_sel;
        end
        ax = axes(fig,'Position', [x0, y0, 0.37 0.34]); % figure window
        hold on;
        
        fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        ib = 0;
        for iband = Bands
            ib = ib+1;
            data_sel = data_sum.(iband)(reg_list,trng)-data_sum.nodist.(iband)(reg_list,trng);
            data_avg = nanmean(data_sel);
            data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
            data_avg = smoothdata(data_avg,'gaussian',gaus_win);
            data_ste = smoothdata(data_ste,'gaussian',gaus_win);
            data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
            
            fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            plot(time_sel,data_avg,'Color',cband{ib},'LineWidth',1.5,'DisplayName',iband);
            xlim(tlim); ylim([-0.05,0.18]);
            xlabel('Time from Sample Onset [s]','FontSize',12);
            ylabel('\Delta Burst Probability','FontSize',12);
            legend('boxoff')
            title(ax,sprintf('Monkey %s %s, n = %d',ianm,ireg,sum(reg_list)),'FontSize',20);
        end
    end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'GrandAvg_BR_region_diffdist_anm'),'-depsc')
print(fullfile(outfigf,'GrandAvg_BR_region_diffdist_anm'),'-dpng')
