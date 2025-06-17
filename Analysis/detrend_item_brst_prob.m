% Plot publication figures for detrended item-numerosity attenuated
% burst-prob.
close all
clear

outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand/data_sum','data_sum');
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/4.BurstStat/Rate_NewBand';

%% Popularize
Bands = ["Beta","LowGamma","HighGamma"]; time = -1:1/1000:4;
prog = 0.0;
fprintf('>>> Loading Data, completed %3.0f%%\n',prog)
for ireg = ["PFC","VIP"]
    reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
    for iband = Bands
        br_anm.(ireg).(iband) = nan(sum(reg_list),4,5,length(time));
    end
    
    files_sel = data_sum.files(reg_list);
    for ifile = 1:numel(files_sel)
        load(fullfile(inf,files_sel{ifile}),'burst_rate');
        for iband = Bands
            for isamp = 1:4
                for idist = 1:5
                    br_anm.(ireg).(iband)(ifile,isamp,idist,:) = burst_rate.(iband){isamp,idist};
                end
            end
        end
        prog = ifile/numel(files_sel)*100;
        fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
    end
end

%% Anova:
% ANOVA parameters
win = 200/1000; % ms2s
trng = time>=-0.5&time<=3.2; step = 20; t_ds = downsample(time(trng),step);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add statistics: gliding-window anova with the four
% numerosities (ignoring D0)
anova = struct();
for ireg = ["PFC","VIP"]
    reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
    for iband = Bands
        for isplit = ["samp","dist"]
            data_sel = br_anm.(ireg).(iband);
            switch isplit
                case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                case 'dist'; data_sel = squeeze(nanmean(data_sel,2)); data_sel = data_sel(:,2:end,:);
            end
            anova.(ireg).(iband).(isplit) = arrayfun(@(ti) anova1(nanmean(data_sel(:,:,time>=(ti-win/2)&time<=(ti+win/2)),3),[],'off'),t_ds);
            fprintf('>>> Completed %s %s %s \n',ireg,iband,isplit);
        end
    end
end
anova.cfg.win = win; anova.cfg.step = step;
anova.cfg.t_ds = t_ds;
save('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand_demix/Animal/anova_result_poolanm.mat','anova');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand_demix/Animal/anova_result_poolanm.mat','anova');

%% Plot the figures, pooling over two monkeys
close all
fig = figure('Position',[50 50 1200 900], 'Visible', true);
% colormap
cx = [248 188 61; 129 189 92; 40 168 224]./255; xc = 1;
for iband = Bands; c.(iband) = cx(xc,:); xc = xc+1; end
% cband = {'b','r','g'};
grey = ones(1,3).*0.5;
gaus_win = 150;
yl = [0.1;0.03;0.04]*[-1,1];

alpha95 = 0.05;
alpha99 = 0.01;

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.1;
        case 'VIP'; x0 = 0.57;
    end
    reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
    
    for isplit = ["samp","dist"]
        switch isplit
            case 'samp'; y0 = 0.57;
            case 'dist'; y0 = 0.1;
        end
        ib = 0;
        for iband = Bands
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % main figure windows
            ax = axes(fig,'Position', [x0,y0+0.125*ib,0.37,0.105]); ib = ib+1; hold on;
            fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            cline = c.(iband)./255;
            data_sel = br_anm.(ireg).(iband);
            switch isplit
                case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                case 'dist'; data_sel = squeeze(nanmean(data_sel,2));
            end
            data_avg = squeeze(nanmean(data_sel));
            data_ste = squeeze(nanstd(data_sel,0,1)./sqrt(size(data_sel,1)));
            for item = 1:size(data_avg,1)
                avg_sel = smoothdata(data_avg(item,:)-nanmean(data_avg),'gaussian',gaus_win);
                ste_sel = smoothdata(data_ste(item,:),'gaussian',gaus_win);
                if strcmp(isplit,'dist')
                    nameline = sprintf('%s%d',upper(isplit{1}(1)),item-1);
                else
                    nameline = sprintf('%s%d',upper(isplit{1}(1)),item);
                end
                % Add the trend-lines
                l = plot(time,avg_sel,'Color',[cline,item/size(data_avg,1)],'LineWidth',2,'DisplayName',nameline);
                if strcmp(isplit,'dist') & item ==1; l.LineStyle = '--'; end
%                 fill([time(trng),fliplr(time(trng))],[avg_sel(trng)+ste_sel(trng),fliplr(avg_sel(trng)-ste_sel(trng))],...
%                     cline,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
                lg = legend('boxoff'); set(lg,'orientation','horizontal','Location','southeast');
            end
            ylim(yl(ib,:));
            xlim([-0.5,3.2]);
            if ib>1; xticks([]); else; xlabel('Time to Sample Onset [s]'); end
            ylabel(iband,'FontSize',10);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % significant lines
            ax = axes(fig,'Position', [x0, y0+0.125*ib-0.02,0.37,0.005]); axis off; hold on;
            p = anova.(ireg).(iband).(isplit);
            resmat = nan(7,length(t_ds));
            resmat(:,p<alpha99) = 1; resmat(3:5,p<alpha95) = 1;
            resmat3d = cat(3,resmat.*cline(1),resmat.*cline(2),resmat.*cline(3));
            image(t_ds,1:7,resmat3d,'AlphaData',~isnan(resmat)); xlim([-0.5,3.2]); ylim([0.5 7.5]);
            set(gca,'color',[1 1 1]);
        end
        ax = axes(fig,'Position',[x0-0.02,y0,0.41,0.37],'Visible','off');
        title(ax,sprintf('%s',ireg),'Visible','on','FontSize',20);
        ylabel(ax,isplit,'Visible','on','FontSize',20);
    end
end

set(fig, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(fig, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'Item_BR_region'),'-depsc')
print(fullfile(outfigf,'Item_BR_region'),'-dpng')
print(fullfile(outfigf,'Item_BR_region'),'-dpdf','-r0')

%% Plot the figures, pooling over two monkeys, no D0
close all
fig = figure('Position',[0 0 800 800], 'Visible', true);
grey = ones(1,3).*0.5;
gaus_win = 150;
yl = [0.05;0.018;0.02]*[-1,1];

alpha95 = 0.05;
alpha99 = 0.01;

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.1;
        case 'VIP'; x0 = 0.57;
    end
    reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
    
    for isplit = ["samp","dist"]
        switch isplit
            case 'samp'; y0 = 0.57;
            case 'dist'; y0 = 0.1;
        end
        ib = 0;
        for iband = Bands
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % main figure windows
            ax = axes(fig,'Position', [x0,y0+0.125*ib,0.37,0.105]); ib = ib+1; hold on;
            fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            
            data_sel = br_anm.(ireg).(iband)(:,:,2:5,:);
            switch isplit
                case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                case 'dist'; data_sel = squeeze(nanmean(data_sel,2));
            end
            data_avg = squeeze(nanmean(data_sel));
            data_ste = squeeze(nanstd(data_sel,0,1)./sqrt(size(data_sel,1)));
            for item = 1:4
                avg_sel = smoothdata(data_avg(item,:)-nanmean(data_avg),'gaussian',gaus_win);
                ste_sel = smoothdata(data_ste(item,:),'gaussian',gaus_win);
                nameline = sprintf('%s%d',upper(isplit{1}(1)),item);
                cline = c.(iband)./255;
                % Add the trend-lines
%                 fill([time(trng),fliplr(time(trng))],[avg_sel(trng)+ste_sel(trng),fliplr(avg_sel(trng)-ste_sel(trng))],...
%                     cline,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
                l = plot(time,avg_sel,'Color',[cline,(item+1)/5],'LineWidth',1,'DisplayName',nameline);
                lg = legend('boxoff'); set(lg,'orientation','horizontal','Location','southeast');
            end
            ylim(yl(ib,:));
            xlim([-0.5,3.2]);
            if ib>1; xticks([]); else; xlabel('Time to Sample Onset [s]'); end
            ylabel(iband,'FontSize',10);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % significant lines
            ax = axes(fig,'Position', [x0, y0+0.125*ib-0.02,0.37,0.005]); axis off; hold on;
            p = anova.(ireg).(iband).(isplit);
            resmat = nan(7,length(t_ds));
            resmat(:,p<alpha99) = 1; resmat(3:5,p<alpha95) = 1;
            resmat3d = cat(3,resmat.*cline(1),resmat.*cline(2),resmat.*cline(3));
            image(t_ds,1:7,resmat3d,'AlphaData',~isnan(resmat)); xlim([-0.5,3.2]); ylim([0.5 7.5]);
            set(gca,'color',[1 1 1]);
        end
        ax = axes(fig,'Position',[x0-0.02,y0,0.41,0.37],'Visible','off');
        title(ax,sprintf('%s',ireg),'Visible','on','FontSize',20);
        ylabel(ax,isplit,'Visible','on','FontSize',20);
    end
end

set(fig, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(fig, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'Item_BR_region_D'),'-depsc')
print(fullfile(outfigf,'Item_BR_region_D'),'-dpng')
print(fullfile(outfigf,'Item_BR_region_D'),'-dpdf','-r0')

%% Plot the figures, pooling over monkeys, separate for PFC and VIP
close all
fig = figure('Position',[0 0 800 800], 'Visible', true);
grey = ones(1,3).*0.5;
gaus_win = 150;
yl = [0.08;0.03;0.04]*[-1,1];

alpha95 = 0.05;
alpha99 = 0.01;

for ireg = ["PFC","VIP"]
    clf(fig,'reset');
    reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
    
    for isplit = ["samp","dist"]
        switch isplit
            case 'samp'; x0 = 0.1;
            case 'dist'; x0 = 0.57;
        end
        ib = 0;
        for iband = Bands
            switch iband
                case 'Beta'; y0 = 0.1; cb = 'b';
                case 'LowGamma'; y0 = 0.39; cb = 'r';
                case 'HighGamma'; y0 = 0.68; cb = 'g';
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % main figure windows
            ax = axes(fig,'Position', [x0,y0,0.37,0.24]); ib = ib+1; hold on;
            fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            
            data_sel = br_anm.(ireg).(iband);
            switch isplit
                case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                case 'dist'; data_sel = squeeze(nanmean(data_sel,2));
            end
            data_avg = squeeze(nanmean(data_sel));
            data_ste = squeeze(nanstd(data_sel,0,1)./sqrt(size(data_sel,1)));
            for item = 1:size(data_avg)
                avg_sel = smoothdata(data_avg(item,:)-nanmean(data_avg),'gaussian',gaus_win);
                ste_sel = smoothdata(data_ste(item,:),'gaussian',gaus_win);
                if strcmp(isplit,'dist')
                    nameline = sprintf('%s%d',upper(isplit{1}(1)),item-1);
                    cline = c.(iband).*cmline(item);
                else
                    nameline = sprintf('%s%d',upper(isplit{1}(1)),item);
                    cline = c.(iband).*cmline(item+1);
                end
                cline(cline>1) = 1;
                % Add the trend-lines
                fill([time(trng),fliplr(time(trng))],[avg_sel(trng)+ste_sel(trng),fliplr(avg_sel(trng)-ste_sel(trng))],...
                    cline,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
                l = plot(time,avg_sel,'Color',cline,'LineWidth',0.5,'DisplayName',nameline);
                if strcmp(isplit,'dist') && item ==1; l.LineStyle = '--'; end
                lg = legend('boxoff'); set(lg,'orientation','horizontal','Location','southeast');
            end
            ylim(yl(ib,:));
            xlim([-0.5,3.2]);
            if ib>1; xticks([]); else; xlabel('Time to Sample Onset [s]'); end
            if ib==3; title(isplit,'FontSize',15); end
            if strcmp(isplit,'samp'); ylabel(iband,'FontSize',15); end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % significant lines
            ax = axes(fig,'Position', [x0, y0+0.235,0.37,0.005]); axis off; hold on;
            p = anova.(ireg).(iband).(isplit);
            resmat = nan(7,length(t_ds));
            resmat(:,p<alpha99) = 1; resmat(3:5,p<alpha95) = 1;
            resmat3d = cat(3,resmat.*cline(1),resmat.*cline(2),resmat.*cline(3));
            image(t_ds,1:7,resmat3d,'AlphaData',~isnan(resmat)); xlim([-0.5,3.2]); ylim([0.5 7.5]);
            set(gca,'color',[1 1 1]);
        end
    end
    ax = axes(fig,'Position',[0.1,0.1,0.8,0.85],'Visible','off');
    title(ax,ireg,'FontSize',20,'Visible','on');
    
    set(fig, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(fig, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outfigf,sprintf('Item_BR_region_%s',ireg)),'-depsc')
    print(fullfile(outfigf,sprintf('Item_BR_region_%s',ireg)),'-dpng')
    print(fullfile(outfigf,sprintf('Item_BR_region_%s',ireg)),'-dpdf','-r0')
end

%% Plot the figures, pooling over monkeys, separate for PFC and VIP, no D0
close all
fig = figure('Position',[0 0 800 800], 'Visible', true);
% colormap
cmline = linspace(0,1,5);
xc = 1;
for iband = Bands; c.(iband) = cx(xc,:); xc = xc+1; end
% cband = {'b','r','g'};
grey = ones(1,3).*0.5;
gaus_win = 150;
yl = [0.08;0.03;0.04]*[-1,1];

alpha95 = 0.05;
alpha99 = 0.01;

for ireg = ["PFC","VIP"]
    clf(fig,'reset');
    reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
    
    for isplit = ["samp","dist"]
        switch isplit
            case 'samp'; x0 = 0.1;
            case 'dist'; x0 = 0.57;
        end
        ib = 0;
        for iband = Bands
            switch iband
                case 'Beta'; y0 = 0.1; cb = 'b';
                case 'LowGamma'; y0 = 0.39; cb = 'r';
                case 'HighGamma'; y0 = 0.68; cb = 'g';
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % main figure windows
            ax = axes(fig,'Position', [x0,y0,0.37,0.24]); ib = ib+1; hold on;
            fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            
            data_sel = br_anm.(ireg).(iband)(:,:,2:5,:);
            switch isplit
                case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                case 'dist'; data_sel = squeeze(nanmean(data_sel,2));
            end
            data_avg = squeeze(nanmean(data_sel));
            data_ste = squeeze(nanstd(data_sel,0,1)./sqrt(size(data_sel,1)));
            for item = 1:4
                avg_sel = smoothdata(data_avg(item,:)-nanmean(data_avg),'gaussian',gaus_win);
                ste_sel = smoothdata(data_ste(item,:),'gaussian',gaus_win);
                nameline = sprintf('%s%d',upper(isplit{1}(1)),item);
                cline = c.(iband).*cmline(item+1);
                cline(cline>1) = 1;
                % Add the trend-lines
                fill([time(trng),fliplr(time(trng))],[avg_sel(trng)+ste_sel(trng),fliplr(avg_sel(trng)-ste_sel(trng))],...
                    cline,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
                l = plot(time,avg_sel,'Color',cline,'LineWidth',0.5,'DisplayName',nameline);
                lg = legend('boxoff'); set(lg,'orientation','horizontal','Location','southeast');
            end
            ylim(yl(ib,:));
            xlim([-0.5,3.2]);
            if ib>1; xticks([]); else; xlabel('Time to Sample Onset [s]'); end
            if ib==3; title(isplit,'FontSize',15); end
            if strcmp(isplit,'samp'); ylabel(iband,'FontSize',15,'Color',c.(iband)); end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % significant lines
            ax = axes(fig,'Position', [x0, y0+0.235,0.37,0.005]); axis off; hold on;
            p = anova.(ireg).(iband).(isplit);
            resmat = nan(7,length(t_ds));
            resmat(:,p<alpha99) = 1; resmat(3:5,p<alpha95) = 1;
            resmat3d = cat(3,resmat.*cline(1),resmat.*cline(2),resmat.*cline(3));
            image(t_ds,1:7,resmat3d,'AlphaData',~isnan(resmat)); xlim([-0.5,3.2]); ylim([0.5 7.5]);
            set(gca,'color',[1 1 1]);
        end
    end
    ax = axes(fig,'Position',[0.1,0.1,0.8,0.85],'Visible','off');
    title(ax,ireg,'FontSize',20,'Visible','on');
    
    set(fig, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(fig, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
%     print(fullfile(outfigf,sprintf('Item_BR_region_%s_D',ireg)),'-depsc')
    print(fullfile(outfigf,sprintf('Item_BR_region_%s_D',ireg)),'-dpng')
    print(fullfile(outfigf,sprintf('Item_BR_region_%s_D',ireg)),'-dpdf','-r0')
end