% copy burst prob. pipeline and modify into burst duration (lifetime) and
% amplitude traces
close all
clear

infold = fullfile('../Data','3.Bursts_inclerror','no_sat_1cyc');
infile = dir(fullfile(infold,'*.mat'));
nfile = length(infile);
files = {infile.name};
outf = '../Data/4.BurstStat/OtherProp';
load('../Data/Chansum.mat');

% test channel
get_other_prop(data_sum.files{1},infold,outf);

delete(gcp('nocreate'))
pools = parpool(32);

parfor ifile = 1:nfile
    get_other_prop(files{ifile},infold,outf);
end

%% Popularize data_sum
% with multiunit properties: duration (DUR) and amplitude (AMP)
data_sum = struct();
data_sum.files = files;
data_sum.time = -1:1e-3:4;
data_sum.Region = ChanSum.region;
inf = outf;
for icond = ["DUR","AMP","FRQ","FSD"]
    for iBand = ["HighGamma","LowGamma","Beta"]
        data_sum.(strcat(icond,'_avg')).(iBand) = nan(numel(files),length(data_sum.time));
    end
end

prog = 0.0;
fprintf('>>> Completed %3.0f%%\n',prog)
for i = 1:numel(files)
    load(fullfile(inf,files{i}),'burst_prop');
    for iBand = ["HighGamma","LowGamma","Beta"]
        for icond = ["DUR","AMP","FRQ","FSD"]
            data_sum.(icond).(iBand){i} = burst_prop.(icond).(iBand);
            data_sum.(strcat(icond,'_avg')).(iBand)(i,:) = nanmean(vertcat(burst_prop.(icond).(iBand){:}));
        end
    end
    prog = i/numel(files)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
save(fullfile(outf,'data_sum'),'data_sum');

%% Plot Grandavg
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

for icond = ["DUR","AMP","FRQ","FSD"]
    clf(fig,'reset');
    for ireg = ["PFC","VIP"]
        switch ireg
            case 'PFC'; x0 = 0.1; reg_list = PFC_idx;
            case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx;
        end
        y0 = 0.12;
        ax = axes(fig,'Position', [x0, y0, 0.37 0.76]); % figure window
        hold on;
        
        ib = 0;
        for iband = Bands
            ib = ib+1;
            data_sel = data_sum.(strcat(icond,'_avg')).(iband)(reg_list,trng);
            data_avg = nanmean(data_sel);
            data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
            data_avg = smoothdata(data_avg,'gaussian',gaus_win);
            data_ste = smoothdata(data_ste,'gaussian',gaus_win);
            data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
            
            plot(time_sel,data_avg,'Color',cband{ib},'LineWidth',2,'DisplayName',iband);
            fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.5,'EdgeColor',cband{ib},'EdgeAlpha',0.1,'HandleVisibility','off');
        end
        switch icond
            case 'DUR'
                ylabel('Average Burst Lifetime [cyc]','FontSize',12); yl = [1.8 3.2];
            case 'AMP'
                ylabel('Average Burst Amplitude [z]','FontSize',12); yl = [3 5];
            case 'FRQ'
                ylabel('Average Frequency [Hz]','FontSize',12); yl = [15 90]; % needs to check
            case 'FSD'
                ylabel('Average Frequency Width [Hz]','FontSize',12); yl = [4 7];
        end
        fill(ax,[0 0.5 0.5 0],yl([2 2 1 1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[1.5 2 2 1.5],yl([2 2 1 1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill(ax,[3 3.5 3.5 3],yl([2 2 1 1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        xlim(tlim); ylim(yl);
        xlabel('Time from sample onset [s]','FontSize',12);
        legend('boxoff')
        title(ax,sprintf('%s, n = %d',ireg,sum(reg_list)),'FontSize',20);
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    print(fullfile(outf,sprintf('GrandAvg_%s_region',icond)),'-depsc')
    print(fullfile(outf,sprintf('GrandAvg_%s_region',icond)),'-dpng')
end

%% Compute detrend, compute anova
for icond = ["DUR","AMP","FRQ","FSD"]
    for iband = Bands
        br_anm.(icond).(iband) = nan(numel(files),4,4,length(data_sum.time));
        for i = 1:numel(files)
            for isamp = 1:4
                for idist = 1:4
                    br_anm.(icond).(iband)(i,isamp,idist,:) = data_sum.(icond).(iband){i}{isamp,idist};
                end
            end
        end
    end
end
% ANOVA parameters
win = 200/1000; % ms2s
time = data_sum.time;
trng = time>=-0.5&time<=3.2; step = 20; t_ds = downsample(time(trng),step);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add statistics: gliding-window anova with the four
% numerosities (ignoring D0)
anova = struct();
for icond = ["DUR","AMP","FRQ","FSD"]
    for ireg = ["PFC","VIP"]
        reg_list = cellfun(@(s) strcmp(s,ireg),data_sum.Region);
        for iband = Bands
            for isplit = ["samp","dist"]
                data_sel = br_anm.(icond).(iband)(reg_list,:,:,:);
                switch isplit
                    case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                    case 'dist'; data_sel = squeeze(nanmean(data_sel,2));
                end
                anova.(icond).(ireg).(iband).(isplit) = arrayfun(@(ti) anova1(nanmean(data_sel(:,:,time>=(ti-win/2)&time<=(ti+win/2)),3),[],'off'),t_ds);
                fprintf('>>> Completed %s %s %s \n',ireg,iband,isplit);
            end
        end
    end
end
anova.cfg.win = win; anova.cfg.step = step;
anova.cfg.t_ds = t_ds;
% save(fullfile(outf,'br_anm'),'br_anm');
save(fullfile(outf,'anova'),'anova');

%% Plot the figures, pooling over monkeys, separate for PFC and VIP
close all
fig = figure('Position',[50 50 900 1200], 'Visible', true);
% colormap
cmline = linspace(0,1,5);
cx = [0 0 1; 1 0 0; 0 1 0]; xc = 1;
for iband = Bands; c.(iband) = cx(xc,:); xc = xc+1; end
% cband = {'b','r','g'};
grey = ones(1,3).*0.5;
gaus_win = 150;

alpha95 = 0.05;
alpha99 = 0.01;

for icond = ["DUR","AMP","FRQ","FSD"]
    switch icond
        case 'DUR'; yl = 0.1 * [-1 1];
        case 'AMP'; yl = 0.2 * [-1 1];
        case 'FRQ'; yl = [-1 1];
        case 'FSD'; yl = 0.15 * [-1 1];
    end
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
                
                data_sel = br_anm.(icond).(iband)(reg_list,:,:,:);
                switch isplit
                    case 'samp'; data_sel = squeeze(nanmean(data_sel,3));
                    case 'dist'; data_sel = squeeze(nanmean(data_sel,2));
                end
                data_avg = squeeze(nanmean(data_sel));
                data_ste = squeeze(nanstd(data_sel,0,1)./sqrt(size(data_sel,1)));
                for item = 1:size(data_avg)
                    avg_sel = smoothdata(data_avg(item,:)-nanmean(data_avg),'gaussian',gaus_win);
                    ste_sel = smoothdata(data_ste(item,:),'gaussian',gaus_win);
                    nameline = sprintf('%s%d',upper(isplit{1}(1)),item);
                    cline = c.(iband).*cmline(item+1);
                    cline(cline>1) = 1;
                    % Add the trend-lines
                    l = plot(time,avg_sel,'Color',cline,'LineWidth',2,'DisplayName',nameline);
                    fill([time(trng),fliplr(time(trng))],[avg_sel(trng)+ste_sel(trng),fliplr(avg_sel(trng)-ste_sel(trng))],...
                        cline,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
                    lg = legend('boxoff'); set(lg,'orientation','horizontal','Location','southeast');
                end
                xlim([-0.5,3.2]);
                if ib>1; xticks([]); else; xlabel('Time to Sample Onset [s]'); end
                if ib==3; title(isplit,'FontSize',15); end
                if strcmp(isplit,'samp'); ylabel(iband,'FontSize',15); end
                
                fill(ax,[0 0.5 0.5 0],yl([2 2 1 1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
                fill(ax,[1.5 2 2 1.5],yl([2 2 1 1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
                fill(ax,[3 3.5 3.5 3],yl([2 2 1 1]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
                
                ylim(yl);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % significant lines
                ax = axes(fig,'Position', [x0, y0+0.235,0.37,0.005]); axis off; hold on;
                p = anova.(icond).(ireg).(iband).(isplit);
                resmat = nan(7,length(t_ds));
                resmat(:,p<alpha99) = 1; resmat(3:5,p<alpha95) = 1;
                resmat3d = cat(3,resmat.*cline(1),resmat.*cline(2),resmat.*cline(3));
                image(t_ds,1:7,resmat3d,'AlphaData',~isnan(resmat)); xlim([-0.5,3.2]); ylim([0.5 7.5]);
                set(gca,'color',[1 1 1]);
            end
        end
        ax = axes(fig,'Position',[0.1,0.1,0.8,0.85],'Visible','off');
        title(ax,ireg,'FontSize',20,'Visible','on');
        
        set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
        set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
        print(fullfile(outf,sprintf('Item_%s_region_%s',icond,ireg)),'-depsc')
        print(fullfile(outf,sprintf('Item_%s_region_%s',icond,ireg)),'-dpng')
    end
end

%%
function get_other_prop(channame,inf,outf)
% includes also frequency center and frequency width
load(fullfile(inf,channame),'data_burst');

burst_prop = struct();
trialinfo = data_burst.trialinfo(~data_burst.badtrials' & data_burst.trialinfo.errorcode==0,:); % only correct trials
% get mean burst properties by iterating 25 times for the stratification
max_iter = 25;
for iBand = ["HighGamma","LowGamma","Beta"]
    switch iBand
        case 'HighGamma'; frng = [60 90];
        case 'LowGamma'; frng = [35 60];
        case 'Beta'; frng = [15 35];
    end
    
    burst_sel = cellfun(@(x) x(x.f>=frng(1) & x.f<frng(2),:),trialinfo.bursts, 'uni',0);
    for iter = 1:max_iter
        idx = sort_condition_sampxdist(trialinfo,'no');
        if iter == 1
            burst_prop.DUR.(iBand) = cellfun(@(x) width_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0);
            burst_prop.AMP.(iBand) = cellfun(@(x) amp_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0);
            burst_prop.FRQ.(iBand) = cellfun(@(x) freq_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0);
            burst_prop.FSD.(iBand) = cellfun(@(x) fsd_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0);
        else
            burst_prop.DUR.(iBand) = cellfun(@plus, burst_prop.DUR.(iBand), cellfun(@(x) width_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0),'uni',0);
            burst_prop.AMP.(iBand) = cellfun(@plus, burst_prop.AMP.(iBand), cellfun(@(x) amp_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0),'uni',0);
            burst_prop.FRQ.(iBand) = cellfun(@plus, burst_prop.FRQ.(iBand), cellfun(@(x) freq_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0),'uni',0);
            burst_prop.FSD.(iBand) = cellfun(@plus, burst_prop.FSD.(iBand), cellfun(@(x) fsd_trace(burst_sel(x,:),data_burst.time)', idx,'uni',0),'uni',0);
        end
    end
    burst_prop.DUR.(iBand) = cellfun(@(x) x/max_iter,burst_prop.DUR.(iBand),'uni',0);
    burst_prop.AMP.(iBand) = cellfun(@(x) x/max_iter,burst_prop.AMP.(iBand),'uni',0);
    burst_prop.FRQ.(iBand) = cellfun(@(x) x/max_iter,burst_prop.FRQ.(iBand),'uni',0);
    burst_prop.FSD.(iBand) = cellfun(@(x) x/max_iter,burst_prop.FSD.(iBand),'uni',0);
end

save(fullfile(outf,channame),'burst_prop');
fprintf('>>> Completed %s\n',channame);
end