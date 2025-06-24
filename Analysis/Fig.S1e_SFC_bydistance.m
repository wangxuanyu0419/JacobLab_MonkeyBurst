% Plot SFC as a function of distance, both within and across channel
% plotted. Log scale on SFC used.
% 
% - all-trl, sorted, by distance
clear; close all; clc;
strname = 'SFC_alltrl_sorted';
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/crsschan';
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
load(fullfile(inf,strname),'SFC_sum');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/7.BTA_multi/multi_mod.mat','multi_mod');
cond = 'PFC_PFC'; % only PFC-PFC pairs have distance information
data = SFC_sum.(cond);
binedges = -0.5:9.5;
idx = discretize(data.distance,binedges);
f = SFC_sum.freq;
%% plot
close all; fig = figure('Position',[0 0 800 600]);
cmap = colormap(turbo); n = floor(size(cmap,1)/10); cmap = cmap(n.*(0:9)+1,:);
% alpha99 = 0.01; alpha95 = 0.05;
for iband = ["HighGamma","LowGamma","Beta"]
    [~,ib] = ismember(iband,SFC_sum.cfg.Bands);
    switch iband
        case 'HighGamma'; x0 = 0.08; cb = [248 188 61];
        case 'LowGamma'; x0 = 0.4; cb = [129 189 92];
        case 'Beta'; x0 = 0.72; cb = [40 168 224];
    end
    for icond = 1:2
        cond = SFC_sum.cfg.conds{icond};
        switch cond
            case 'in'; y0 = 0.53;
            case 'out'; y0 = 0.1;
        end
        axes(fig,'Position',[x0 y0 0.27 0.3]); hold on;
        ppcs = cellfun(@(d) squeeze(d(ib,icond,:)),data.ppc,'uni',0);
        for i = 1:10
            ppc = horzcat(ppcs{idx==i})';
            m = nanmean(ppc);
            plot(f,m,'Color',cmap(i,:),'DisplayName',sprintf('d = %d',i-1));
        end
        if icond==1 % 'in' plot, duplicate an out d=0 dash line
            % in0
            ppc_in = horzcat(ppcs{idx==1})';
            % out0
            ppcs = cellfun(@(d) squeeze(d(ib,2,:)),data.ppc,'uni',0);
            ppc_out = horzcat(ppcs{idx==1})';
            % plot dashed line
            m = nanmean(ppc_out);
            plot(f,m,'--','Color',cmap(1,:),'DisplayName',sprintf('d = %d',i-1));
            % compute statistics: ttest
            p = nan(size(ppc,2),1);
            for fi = 1:size(ppc,2)
                [~,p(fi)] = ttest(ppc_in(:,fi),ppc_out(:,fi));
            end
        end
        xlabel('Frequency [Hz]'); ylabel('SFC');
        ylim([-0.002 0.08]); xlim([4 90]);
        title(strcat(iband,'_{',cond,'}'),'Color',cb./255);
        set(gca,'TickDir','out');
%         if icond==1 % plot significance bar
%             ax = axes(fig,'Position',[x0, y0+0.3, 0.37,0.01]); axis off; hold on;
%             resmat = nan(7,length(p));
%             resmat(:,p<alpha99) = 1; resmat(3:5,p<alpha95) = 1;
%             resmat3d = cat(3,resmat.*cb(1),resmat.*cb(2),resmat.*cb(3));
%             image(f,1:7,resmat3d,'AlphaData',~isnan(resmat)); xlim([4 90]); ylim([0.5 7.5]);
%         end
    end
end
axes(fig,'Visible','off'); title('Spike-field coupling by distance _{PFC-PFC}','FontSize',15,'Visible','on');
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,strcat(strname,'_bydist')),'-depsc');
print(fullfile(outfigf,strcat(strname,'_bydist')),'-dpng');
print(fullfile(outfigf,strcat(strname,'_bydist')),'-dpdf','-r0');
%% plot log
close all; fig = figure('Position',[0 0 800 600]);
cmap = colormap(turbo); n = floor(size(cmap,1)/10); cmap = cmap(n.*(0:9)+1,:);
alpha99 = 0.01; alpha95 = 0.05;
for iband = ["HighGamma","LowGamma","Beta"]
    [~,ib] = ismember(iband,SFC_sum.cfg.Bands);
    switch iband
        case 'HighGamma'; x0 = 0.08; cb = [248 188 61];
        case 'LowGamma'; x0 = 0.4; cb = [129 189 92];
        case 'Beta'; x0 = 0.72; cb = [40 168 224];
    end
    for icond = 1:2
        cond = SFC_sum.cfg.conds{icond};
        switch cond
            case 'in'; y0 = 0.53;
            case 'out'; y0 = 0.1;
        end
        axes(fig,'Position',[x0 y0 0.27 0.3]); hold on;
        ppcs = cellfun(@(d) squeeze(d(ib,icond,:)),data.ppc,'uni',0);
        for i = 1:10
            ppc = horzcat(ppcs{idx==i})';
            m = nanmean(ppc);
            plot(f,m,'Color',cmap(i,:),'DisplayName',sprintf('d = %d',i-1));
        end
        xlabel('Frequency [Hz]'); ylabel('SFC');
        xlim([4 90]);
        title(strcat(iband,'_{',cond,'}'),'Color',cb./255);
        set(gca,'YScale','log'); xticks([0 15 35 60 90]);
        ylim([0.0001 0.1]);
    end
end
axes(fig,'Visible','off'); title('Spike-field coupling by distance _{PFC-PFC}','FontSize',15,'Visible','on');
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,strcat(strname,'_bydist_log')),'-depsc');
print(fullfile(outfigf,strcat(strname,'_bydist_log')),'-dpng');
%% Plot log-frequency
fl = log2(f); cb = 'br'; ylm = [0.04,0.06];
close all; fig = figure('Position',[0 0 500 600]);
cmap = colormap(turbo); n = floor(size(cmap,1)/10); cmap = cmap(n.*(0:9)+1,:);
for iband = ["HighGamma","Beta"]
    [~,ib] = ismember(iband,["HighGamma","Beta"]);
    [~,ibx] = ismember(iband,SFC_sum.cfg.Bands);
    for icond = 1:2
        cond = SFC_sum.cfg.conds{icond};
        subplot(2,2,ib*2-2+icond); hold on;
        ppcs = cellfun(@(d) squeeze(d(ibx,icond,:)),data.ppc,'uni',0);
        for i = 1:10
            ppc = horzcat(ppcs{idx==i})';
            m = nanmean(ppc);
            plot(fl,m,'Color',cmap(i,:),'LineWidth',1,'DisplayName',sprintf('d = %d',i-1));
        end
        if icond==1 % 'in' plot, duplicate an out d=0 dash line
            % in0
            ppc_in = horzcat(ppcs{idx==1})';
            % out0
            ppcs = cellfun(@(d) squeeze(d(ibx,2,:)),data.ppc,'uni',0);
            ppc_out = horzcat(ppcs{idx==1})';
            % plot dashed line
            m = nanmean(ppc_out);
            plot(fl,m,'--','Color',cmap(1,:),'LineWidth',1,'DisplayName',sprintf('d = %d',i-1));
            % compute statistics: ttest
            p = nan(size(ppc,2),1);
            for fi = 1:size(ppc,2)
                [~,p(fi)] = ttest(ppc_in(:,fi),ppc_out(:,fi));
            end
        end
        xlabel('Frequency [Hz]'); ylabel('SFC');
        ylim([0 ylm(ib)]); xlim([1,7]); xticks(1:7); xticklabels(2.^(1:7));
        title(strcat(iband,'_{',cond,'}'),'Color',cb(ib));
        set(gca,'TickDir','out');
    end
end
set(fig, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(fig, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,strcat(strname,'_bydist_log')),'-dpng');
print(fullfile(outfigf,strcat(strname,'_bydist_log')),'-dpdf','-r0');
