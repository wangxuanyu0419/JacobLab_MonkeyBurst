% Plot publication figure for burst spatial distribution at certain moments
close all; clear; clc;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';
load(fullfile(inf,'AvgBrstSpatial'),'AvgBrstSpatial');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs/burst_spatial_snapshot';
%% Plot separate
tx = [-0.1, 0.10, 0.5, 1.1, 1.64, 2.0, 2.6, 2.9];
tx = [-0.5, 1.5];
smtwin = 100;
time = -1:1/1000:4; c.HG = 'g'; c.BT = 'b';
close all
fig = figure('Position',[0 0 700 600]);
cl.R.HG = {[0.1,0.25],[0.1,0.4],[0.15,0.3],[0.1,0.35],[0.1,0.35]}; cl.R.BT = {[0.1,0.35],[0.1,0.6],[0.1,0.25],[0.1,0.35],[0.05,0.3]};
cl.W.HG = {[0.15,0.25],[0.15,0.35],[0.15,0.3],[0.15,0.3],[0.15,0.3]}; cl.W.BT = {[0.1,0.25],[0.1,0.35],[0.05,0.25],[0.05,0.3],[0.1,0.2]};
cl.HG = [0.1,0.4]; cl.BT = [0.1,0.5];
for ian = ["R","W"]
    BT.(ian) = smoothdata(AvgBrstSpatial.(ian).Beta_avg,2,'gaussian',smtwin);
    HG.(ian) = smoothdata(AvgBrstSpatial.(ian).HighGamma_avg,2,'gaussian',smtwin);
end
for ti = 1:length(tx)
    [~,tidx] = min(abs(time-tx(ti)));
    clf(fig,'reset');
    for ian = ["R","W"]
        switch ian
            case 'R'; y0 = 0.55;
            case 'W'; y0 = 0.1;
        end
        for iband = ["HG","BT"]
            switch iband
                case 'HG'; x0 = 0.15; data = HG.(ian);
                case 'BT'; x0 = 0.6; data = BT.(ian);
            end
            ax = axes(fig,'Position',[x0,y0,0.37,0.34]); hold on;
            xlim(ax,[-7 4]); ylim(ax,[-6 5]);
            h = get_chan_layout(ax,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
            clx = cl.(iband);
            clim(clx); cmap = colormap(jet);
            zscl = linspace(clx(1),clx(2),size(cmap,1));
            for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
                [~,zx] = min(abs(zscl-data(ich,tidx)));
                h{ich}.FaceColor = cmap(zx,:);
            end
            cb = colorbar; clim(clx); cb.Label.String = 'Burst Prob.';
            if strcmp(iband,'HG'); ylabel(ian,'FontSize',15); end
            if strcmp(ian,'R'); title(iband,'Color',c.(iband),'FontSize',15); end
        end
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outf,sprintf('t_%.02f.png',tx(ti))),'-dpng');
    print(fullfile(outf,sprintf('t_%.02f.pdf',tx(ti))),'-dpdf','-r0','-bestfit');
end

%% Plot in one figure for each animal
close all
fig = figure('Position',[0 0 1300 500]);
x = 0.09:0.17:0.79;
cl.R.HG = [0.1,0.4]; cl.R.BT = [0.1,0.6];
cl.W.HG = [0.1,0.35]; cl.W.BT = [0.05,0.35];

for ian = ["R","W"]
    clf(fig,'reset');
    for iband = ["HG","BT"]
        switch iband
            case 'HG'; y0 = 0.57; data = HG.(ian);
            case 'BT'; y0 = 0.1; data = BT.(ian);
        end
        clx = cl.(ian).(iband);
        for ti = 1:5
            [~,tidx] = min(abs(time-tx(ti)));
            ax = axes(fig,'Position',[x(ti),y0,0.15,0.39]); hold on;
            xlim(ax,[-7 4]); ylim(ax,[-6 5]);
            h = get_chan_layout(ax,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
            clim(clx); cmap = colormap(jet);
            zscl = linspace(clx(1),clx(2),size(cmap,1));
            for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
                [~,zx] = min(abs(zscl-data(ich,tidx)));
                h{ich}.FaceColor = cmap(zx,:);
            end
            switch ian
                case 'R'
                    text(-6,-4,sprintf('t = %.02fs',tx(ti)),'FontSize',10);
                case 'W'
                    text(0,4,sprintf('t = %.02fs',tx(ti)),'FontSize',10);
            end
        end
        ax = axes(fig,'Position',[0.07,y0,0.9,0.39],'Visible','off');
        cb = colorbar; clim(clx); cb.Label.String = 'Burst Prob.';
        ylabel(ax,iband,'FontSize',13,'Color',c.(iband),'Visible','on');
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outf,sprintf('%s_sum.png',ian)),'-dpng');
    print(fullfile(outf,sprintf('%s_sum.eps',ian)),'-depsc');
end

%% add LG figures
close all
fig = figure('Position',[0 0 1300 500]);
x = 0.09:0.17:0.79;
cl.R.LG = [0.1,0.25];
cl.W.LG = [0.1,0.25];
iband = "LG"; c.LG = 'r';

for ian = ["R","W"]
    LG.(ian) = smoothdata(AvgBrstSpatial.(ian).LowGamma_avg,2,'gaussian',smtwin);
end
for ian = ["R","W"]
    clf(fig,'reset');
    y0 = 0.57; data = LG.(ian);
    clx = cl.(ian).(iband);
    for ti = 1:5
        [~,tidx] = min(abs(time-tx(ti)));
        ax = axes(fig,'Position',[x(ti),y0,0.15,0.39]); hold on;
        xlim(ax,[-7 4]); ylim(ax,[-6 5]);
        h = get_chan_layout(ax,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
        clim(clx); cmap = colormap(jet);
        zscl = linspace(clx(1),clx(2),size(cmap,1));
        for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
            [~,zx] = min(abs(zscl-data(ich,tidx)));
            h{ich}.FaceColor = cmap(zx,:);
        end
        switch ian
            case 'R'
                text(-6,-4,sprintf('t = %.02fs',tx(ti)),'FontSize',10);
            case 'W'
                text(0,4,sprintf('t = %.02fs',tx(ti)),'FontSize',10);
        end
        ax = axes(fig,'Position',[0.07,y0,0.9,0.39],'Visible','off');
        cb = colorbar; clim(clx); cb.Label.String = 'Burst Prob.';
        ylabel(ax,iband,'FontSize',13,'Color',c.(iband),'Visible','on');
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outf,sprintf('%s_LG.png',ian)),'-dpng');
    print(fullfile(outf,sprintf('%s_LG.eps',ian)),'-depsc');
end
