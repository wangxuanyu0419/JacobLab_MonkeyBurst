% Plot publication figures for burst width distribution
clear; close all; clc;
% Popularize summary
brst_all = struct();
Inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts/no_sat';
Inf_dir = dir(fullfile(Inf,'*.mat'));
Inf_files = {Inf_dir.name};
brst_all.files = Inf_files;
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

frng.Beta = [15,35];
frng.LowGamma = [35 60];
frng.HighGamma = [60 90];

prog = 0.0;
fprintf('>>> Loading Data, completed %3.0f%%\n',prog)
for ifile = 1:numel(Inf_files)
    load(fullfile(Inf,Inf_files{ifile}),'data_burst');
    bursts = data_burst.trialinfo.bursts(~data_burst.badtrials);
    for iband = ["Beta","LowGamma","HighGamma"]
        frng_sel = frng.(iband);
        brst_all.(iband){ifile} = cellfun(@(b) gauss_fwfracm(b.t_sd(b.f>=frng_sel(1)&b.f<=frng_sel(2),:),1/2), bursts,'uni',0);
        brst_all.cyc.(iband){ifile} = cellfun(@(w,b) w.*b.f(b.f>=frng_sel(1)&b.f<=frng_sel(2)), brst_all.(iband){ifile},bursts,'uni',0);
    end
    prog = ifile/numel(Inf_files)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end

for iband = ["Beta","LowGamma","HighGamma"]
    brst_all.All.(iband) = vertcat(brst_all.(iband){:});
    brst_all.All.(iband) = vertcat(brst_all.All.(iband){:});
    brst_all.All_cyc.(iband) = vertcat(brst_all.cyc.(iband){:});
    brst_all.All_cyc.(iband) = vertcat(brst_all.All_cyc.(iband){:});
end

%% Sort by region
regs = ["PFC","VIP"];
reglist = cellfun(@(s) regs((str2double(s(11:12))<=8)+1),brst_all.files,'uni',0);
for iband = ["Beta","LowGamma","HighGamma"]
    for ireg = regs
        brst_all.(ireg).(iband) = vertcat(brst_all.(iband){cellfun(@(s) strcmp(s,ireg),reglist)});
        brst_all.(ireg).(iband) = vertcat(brst_all.(ireg).(iband){:});
        brst_all.(strcat(ireg,'_cyc')).(iband) = vertcat(brst_all.cyc.(iband){cellfun(@(s) strcmp(s,ireg),reglist)});
        brst_all.(strcat(ireg,'_cyc')).(iband) = vertcat(brst_all.(strcat(ireg,'_cyc')).(iband){:});
    end
end

%% report
for iband = ["Beta","HighGamma"]
%     for ireg = regs
%         for unit = ["ms","cycles"]
%             switch unit
%                 case "ms"
%                     data = brst_all.(ireg).(iband).*1e3;
%                 case "cycles"
%                     data = brst_all.(strcat(ireg,'_cyc')).(iband);
%             end
%             m = mean(data);
%             md = median(data);
%             ste = std(data);
%             fprintf("Lifetime of %s bursts in %s: mean = %.2f %s, median = %.2f %s, standard deviation = %.2f %s\n",iband, ireg, m, unit, md, unit, ste, unit);
%         end
%     end
    for unit = ["ms","cycles"]
        switch unit
            case "ms"
                data = brst_all.All.(iband).*1e3;
            case "cycles"
                data = brst_all.All_cyc.(iband);
        end
        m = mean(data);
        md = median(data);
        ste = std(data);
        fprintf("Lifetime of %s bursts in both regions: mean = %.2f %s, median = %.2f %s, standard deviation = %.2f %s\n",iband, m, unit, md, unit, ste, unit);
    end
end

%% Plot the figure
close all
fig = figure('Position',[100 100 800 250]);
for md = ["t","c"] % t or c (for cycle)
    clf(fig,'reset');
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; x0 = 0.1; cb = 'b';
            case 'LowGamma'; x0 = 0.4; cb = 'r';
            case 'HighGamma'; x0 = 0.7; cb = 'g';
        end
        ax = axes(fig,'Position',[x0,0.18,0.24,0.68]); hold on;
        switch md
            case 't'
                data = brst_all.All.(iband)*1000;
                xlabel('Burst Lifetime [ms]')
            case 'c'
                data = brst_all.All_cyc.(iband);
                xlabel('Burst Lifetime [n_{cycles}]')
        end
        prc95 = prctile(data,[2.5 , 97.5]);
        m = median(data);
        h = histogram(data,'NumBins',60,'HandleVisibility','off');
        set(h,'FaceColor',cb);
        yl = ylim(); plot([m m],yl,'--k','LineWidth',1,'DisplayName',sprintf('median = %.01f',m));
        fill(prc95([1 2 2 1]),yl([2 2 1 1]),cb,'FaceAlpha',0.3,'EdgeAlpha',0.1,'DisplayName',sprintf('95%%CI [%.01f, %.01f]',prc95(1),prc95(2)));
        ylabel('Counts'); xlim([0 8]);
        %legend('boxoff')
        title(iband,'FontSize',15,'Color',cb);
        ax.XAxis.TickDirection = 'out';
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outfigf,sprintf('dist_burst_length_%s',md)),'-depsc');
    print(fullfile(outfigf,sprintf('dist_burst_length_%s',md)),'-dpng');
end

%% Plot by regions, overlap
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs/brst_length_reg';
close all
fig = figure('Position',[100 100 800 250]);
for md = ["t","c"] % t or c (for cycle)
    clf(fig,'reset');
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; x0 = 0.1;
            case 'LowGamma'; x0 = 0.4;
            case 'HighGamma'; x0 = 0.7;
        end
        ax = axes(fig,'Position',[x0,0.18,0.24,0.68]); hold on;
        for ireg = regs
            switch ireg
                case 'PFC'; cb = 'c';
                case 'VIP'; cb = 'm';
            end
            switch md
                case 't'
                    data = brst_all.(ireg).(iband)*1000;
                    xlabel('Burst Lifetime [ms]')
                case 'c'
                    data = brst_all.(strcat(ireg,'_cyc')).(iband);
                    xlabel('Burst Lifetime [n_{cycles}]')
            end
            prc95 = prctile(data,[2.5 , 97.5]);
            m = median(data);
            h = histogram(data,'NumBins',60,'HandleVisibility','off','FaceAlpha',0.3);
            set(h,'FaceColor',cb);
            yl = ylim(); plot([m m],yl,'--','Color',cb,'LineWidth',1,'DisplayName',ireg);
%             fill(prc95([1 2 2 1]),yl([2 2 1 1]),cb,'FaceAlpha',0.2,'EdgeAlpha',0.1,'HandleVisibility','off');
        end
        ylabel('Counts');
        legend('boxoff')
        title(iband,'FontSize',15);
        ax.XAxis.TickDirection = 'out';
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(fig,'Renderer','Painters'); % avoid printing bitmaps
    print(fullfile(outfigf,sprintf('dist_burst_length_%s_reg',md)),'-depsc');
    print(fullfile(outfigf,sprintf('dist_burst_length_%s_reg',md)),'-dpng');
end
