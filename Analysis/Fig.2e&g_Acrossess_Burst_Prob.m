% plot burst prob. fluctuation by spatial location
clear
close all
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand/data_sum.mat','data_sum');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';

% get pattern
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/sess_pattern.mat','sess','pattern_PFC');

%% initiate output
AvgBrstSpatial = struct();
AvgBrstSpatial.Region = 'PFC';
reg_list = cellfun(@(x) strcmp(x,AvgBrstSpatial.Region),data_sum.Region);
AvgBrstSpatial.files = data_sum.files(reg_list);
AvgBrstSpatial.location = cell(size(AvgBrstSpatial.files));
for iband = ["Beta","LowGamma","HighGamma"]
    AvgBrstSpatial.(iband) = data_sum.(iband)(reg_list,:);
end
for ich = 1:sum(reg_list)
    chan = AvgBrstSpatial.files{ich};
    AvgBrstSpatial.location{ich} = pattern_PFC{sess.sess_pat(strcmp(sess.sess_names,chan(1:7)))}{str2double(chan(11:12))};
end

%% sort by location
for ian = ["R","W"]
    AvgBrstSpatial.(ian) = struct();
    anm_list = cellfun(@(s) strcmp(s(1),ian),AvgBrstSpatial.files);
    AvgBrstSpatial.(ian).files = AvgBrstSpatial.files(anm_list);
    AvgBrstSpatial.(ian).location = AvgBrstSpatial.location(anm_list);
    [loc,~,idx] = unique(vertcat(AvgBrstSpatial.(ian).location{:}),'row');
    AvgBrstSpatial.(ian).loc_list = loc;
    for iband = ["Beta","LowGamma","HighGamma"]
        AvgBrstSpatial.(ian).(iband) = AvgBrstSpatial.(iband)(anm_list,:);
        AvgBrstSpatial.(ian).(strcat(iband,'_avg')) = nan(size(loc,1),size(AvgBrstSpatial.(ian).(iband),2));
        for il = 1:size(loc,1)
            AvgBrstSpatial.(ian).(strcat(iband,'_avg'))(il,:) = nanmean(AvgBrstSpatial.(ian).(iband)(idx==il,:));
        end
    end
end
save(fullfile(outfigf,'AvgBrstSpatial'),'AvgBrstSpatial');

%% Plot gif
for ian = ["R","W"]
    for iband = ["Beta","LowGamma","HighGamma"]
        out_n = fullfile(outfigf,'gifs',sprintf('Monkey%s_%s.gif',ian,iband));
        close all
        fig = figure('Position',[10 10 600 600]);
        ax_loc = axes(fig,'Position',[0.1,0.27,0.7,0.67]);
        ax_t = axes(fig,'Position',[0.1,0.06,0.7,0.15]);
        hold on;
        % formulate time figure
        tlim = [-0.5,3.2];
        xlim(ax_t,tlim); ylim(ax_t,[0,3]); yticks(ax_t,[]); xticks(ax_t,[0,0.5,1.5,2,3]);
        hold on; arrayfun(@(x) plot(ax_t,[x x],[1,3],'LineWidth',1.5,'Color','k'),[0,0.5,1.5,2,3]);
        arrayfun(@(y) plot(ax_t,tlim,[y y],'LineWidth',1.5,'Color','k'),[1,3]);
        tx = {'Samp','Mem1','Dist','Mem2'}; tx_loc = [0.25,1,1.75,2.5];
        for i = 1:4
            text(tx_loc(i),2,tx{i},'HorizontalAlignment','center');
        end
        xlabel(ax_t,'Time to sample onset [s]');
        % add the time indicator
        tlp = plot(ax_t,-0.5*ones(1,2),[0,3],'LineWidth',2.5,'Color','r');
        time = -1:1/1000:4; tlim = [-0.5,3.2]; tlist = time>=tlim(1)&time<=tlim(2);
        step = 10; td = downsample(time(tlist),step);
        smtwin = 100;
        % add colorbar
        ax_cb = axes(fig,'Position',[0.1,0.27,0.8,0.67],'Visible','off');
        a = colorbar(ax_cb); a.Label.String = 'Burst Prob.'; %a.Label.Rotation = 270; a.Label.Position(1)= 3;
        % format location window
        xlim(ax_loc,[-7 4]); ylim(ax_loc,[-6 5]);
        title(ax_loc,sprintf('Monkey %s, average %s band burst probability',ian,iband));
        
        % get pattern
        h = get_chan_layout(ax_loc,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
        
        data_all = AvgBrstSpatial.(ian).(strcat(iband,'_avg'))(:,tlist);
        clim = [min(data_all(:)),max(data_all(:))];
        if ian=='R'&&iband=="LowGamma"; clim = [0.05,0.3]; end
        caxis(clim); cmap = colormap(jet);
        zscl = linspace(clim(1),clim(2),size(cmap,1));
        data = downsample(smoothdata(data_all,2,'gaussian',smtwin)',step)';
        for ti = 1:length(td)
            for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
                [~,zx] = min(abs(zscl-data(ich,ti)));
                h{ich}.FaceColor = cmap(zx,:);
            end
            tlp.XData = td(ti)*ones(1,2);
            set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
            set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
            [A,map] = rgb2ind(frame2im(getframe(gcf)),256);
            if ti==1; imwrite(A,map,out_n,'gif','LoopCount',Inf,'DelayTime',0.06);
            else; imwrite(A,map,out_n,'gif','WriteMode','append','DelayTime',0.06); end
        end
    end
end

%% Plot video
outfigavis = '/mnt/storage/xuanyu/MONKEY/Non-ion/14.OCPspatial/AvgBrstSpatial/avis';
for ian = ["R","W"]
    for iband = ["Beta","LowGamma","HighGamma"]
        out_n = fullfile(outfigavis,sprintf('Monkey%s_%s.avi',ian,iband));
        close all
        fig = figure('Position',[10 10 600 600]);
        ax_loc = axes(fig,'Position',[0.1,0.27,0.7,0.67]);
        ax_t = axes(fig,'Position',[0.1,0.06,0.7,0.15]);
        hold on;
        % formulate time figure
        tlim = [-0.5,3.2];
        xlim(ax_t,tlim); ylim(ax_t,[0,3]); yticks(ax_t,[]); xticks(ax_t,[0,0.5,1.5,2,3]);
        hold on; arrayfun(@(x) plot(ax_t,[x x],[1,3],'LineWidth',1.5,'Color','k'),[0,0.5,1.5,2,3]);
        arrayfun(@(y) plot(ax_t,tlim,[y y],'LineWidth',1.5,'Color','k'),[1,3]);
        tx = {'Samp','Mem1','Dist','Mem2'}; tx_loc = [0.25,1,1.75,2.5];
        for i = 1:4
            text(tx_loc(i),2,tx{i},'HorizontalAlignment','center');
        end
        xlabel(ax_t,'Time to sample onset [s]');
        % add the time indicator
        tlp = plot(ax_t,-0.5*ones(1,2),[0,3],'LineWidth',2.5,'Color','r');
        time = -1:1/1000:4; tlim = [-0.5,3.2]; tlist = time>=tlim(1)&time<=tlim(2);
        step = 10; td = downsample(time(tlist),step);
        smtwin = 100;
        % add colorbar
        ax_cb = axes(fig,'Position',[0.1,0.27,0.8,0.67],'Visible','off');
        a = colorbar(ax_cb); a.Label.String = 'Burst Prob.'; %a.Label.Rotation = 270; a.Label.Position(1)= 3;
        % format location window
        xlim(ax_loc,[-7 4]); ylim(ax_loc,[-6 5]);
        title(ax_loc,sprintf('Monkey %s, average %s band burst probability',ian,iband));
        
        % get pattern
        h = get_chan_layout(ax_loc,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
        
        data_all = AvgBrstSpatial.(ian).(strcat(iband,'_avg'))(:,tlist);
        clim = [min(data_all(:)),max(data_all(:))];
        caxis(clim); cmap = colormap(jet);
        zscl = linspace(clim(1),clim(2),size(cmap,1));
        data = downsample(smoothdata(data_all,2,'gaussian',smtwin)',step)';
        v = VideoWriter(out_n,'Uncompressed AVI');
        v.FrameRate = 20;
        open(v);
        for ti = 1:length(td)
            for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
                [~,zx] = min(abs(zscl-data(ich,ti)));
                h{ich}.FaceColor = cmap(zx,:);
            end
            tlp.XData = td(ti)*ones(1,2);
            set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
            set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
            f = getframe(gcf); writeVideo(v,f);
        end
        close(v);
    end
end

%% Plot snapshot figures
tx = -100:200:2900; tx = tx/1000;
time = -1:1/1000:4; tlim = [-0.5,3.2]; tlist = time>=tlim(1)&time<=tlim(2);
smtwin = 100;
Bands = ["Beta","LowGamma","HighGamma"];
for ian = ["R","W"]
    out_n = fullfile(outfigf,sprintf('Monkey%s_series_all.png',ian));
    close all
    fig = figure('Position',[10 10 1280 700]);
    hold on;
    for iband = Bands
        xb = find(strcmp(Bands,iband));
        data_all = AvgBrstSpatial.(ian).(strcat(iband,'_avg'))(:,tlist);
        data = smoothdata(data_all,2,'gaussian',smtwin);
        clim = [min(data_all(:)),max(data_all(:))];
        cmap = colormap(jet);
        zscl = linspace(clim(1),clim(2),size(cmap,1));        
        for ti = 1:length(tx)
            subplot(6,8,16*(xb-1)+ti); hold on
            [~,tidx] = min(abs(time(tlist)-tx(ti)));
            xlim([-7 4]); ylim([-6 5]);
            title(sprintf('t = %.01fs',tx(ti)));
            h = get_chan_layout(gca,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
            caxis(clim); 
            for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
                [~,zx] = min(abs(zscl-data(ich,tidx)));
                h{ich}.FaceColor = cmap(zx,:);
            end
        end
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    print(out_n,'-dpng');
end

%% Plot snapshot with selected time incidices
tx = [-0.1, 0.1, 0.3, 0.6, 1.2, 1.6, 1.8, 2.1, 2.7];
time = -1:1/1000:4; tlim = [-0.5,3.2]; tlist = time>=tlim(1)&time<=tlim(2);
smtwin = 100;
Bands = ["Beta","LowGamma","HighGamma"]; band_color = {'b','r','g'};
xloc = 0.06+0.17*([0:4,1:4]);
for ian = ["R","W"]
    out_n = fullfile(outfigf,sprintf('Monkey%s_series_all.png',ian));
    close all
    fig = figure('Position',[10 10 900 1200]);
    
    % add time stamp plot
    ax_t = axes(fig,'Position',[0.06,0.92,0.86,0.05]);
    title(ax_t,sprintf('Monkey %s',ian),'FontSize',15);
    tlim = [-0.5,3.2];
    xlim(ax_t,tlim); ylim(ax_t,[0.5,3]); yticks(ax_t,[]); xticks(ax_t,[0,0.5,1.5,2,3]);
    hold on; arrayfun(@(x) plot(ax_t,[x x],[1,3],'LineWidth',1.5,'Color','k'),[0,0.5,1.5,2,3]);
    arrayfun(@(y) plot(ax_t,tlim,[y y],'LineWidth',1.5,'Color','k'),[1,3]);
    texts = {'Samp','Mem1','Dist','Mem2'}; tx_loc = [0.25,1,1.75,2.5];
    for i = 1:4
        text(tx_loc(i),2,texts{i},'HorizontalAlignment','center');
    end
    xlabel(ax_t,'Time to sample onset [s]');
    % add the time indicator
    arrayfun(@(x) plot(ax_t,x*ones(1,2),[0,3],'Color','r'),tx);
    arrayfun(@(x) text(x-0.05,2,sprintf('%.01f',x),'FontSize',8,'Color','r','Rotation',90,'HorizontalAlignment','center'),tx);

    for iband = Bands
        xb = find(strcmp(Bands,iband));
        data_all = AvgBrstSpatial.(ian).(strcat(iband,'_avg'))(:,tlist);
        data = smoothdata(data_all,2,'gaussian',smtwin);
        clim = [min(data_all(:)),max(data_all(:))];
        cmap = colormap(jet);
        zscl = linspace(clim(1),clim(2),size(cmap,1));

        yloc = 0.03 + 0.3*(3-xb);
        for ti = 1:length(tx)
            % locate the axes
            if ti <= 5; ylocx = yloc+0.12; else; ylocx = yloc; end
            ax = axes(fig,'Position',[xloc(ti), ylocx, 0.15, 0.1]);
            hold on; xticks(ax,[]); yticks(ax,[]);
            [~,tidx] = min(abs(time(tlist)-tx(ti)));
            xlim(ax,[-7 4]); ylim(ax,[-6 5]);
            title(ax,sprintf('t = %.01fs',tx(ti)));
            h = get_chan_layout(ax,mat2cell(AvgBrstSpatial.(ian).loc_list,ones(size(AvgBrstSpatial.(ian).loc_list,1),1)));
            caxis(clim); 
            for ich = 1:size(AvgBrstSpatial.(ian).loc_list,1)
                [~,zx] = min(abs(zscl-data(ich,tidx)));
                h{ich}.FaceColor = cmap(zx,:);
            end
        end
        ax = axes(fig,'Position',[0.08,yloc,0.88,0.22],'Visible','off');
        cb = colorbar; caxis(clim); cb.Label.String = 'Burst Prob.';
        ylabel(ax,iband,'FontSize',13,'Color',band_color{xb},'Visible','on');
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    print(out_n,'-dpng');
end
