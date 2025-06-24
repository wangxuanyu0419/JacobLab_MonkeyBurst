% Calculate and plot fluctuation of diff(high-low OCP) burst-rate
clear
close all

fd = 'nrank_40_1_r';

inf_spec = fullfile('/mnt/storage/xuanyu/MONKEY/Non-ion/11.PEVBurstOccp/spec_occp',fd);
outf = fullfile('/mnt/storage/xuanyu/JacobLabMonkey/data/11.PEVBurstOccp/',fd);

%% Get data and compute mean
indir = dir(fullfile(inf_spec,'*.mat'));
files = {indir.name};
PFC_list = cellfun(@(s) str2double(s(13:14))<=8,files);

t = -1:1/1000:4;

% Initialize output
br_occp_sum = struct();

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'
            file_reg = files(PFC_list);
        case 'VIP'
            file_reg = files(~PFC_list);
    end
    
%     for iband = ["Beta","LowGamma","HighGamma"]
%         for icond = ["high","low"]
%             br_occp_sum.burstprob.(ireg).(iband).(icond) = nan(numel(file_reg),length(t));
%         end
%         br_occp_sum.burstprob_diff.(ireg).(iband) = nan(numel(file_reg),length(t));
%         br_occp_sum.burstprob_ratio.(ireg).(iband) = nan(numel(file_reg),length(t));
%     end
%     
%     for ifile = 1:numel(file_reg)
%         load(fullfile(inf_spec,file_reg{ifile}),'spec_burst_occp');
%         for iband = ["Beta","LowGamma","HighGamma"]
%             for icond = ["high","low"]
%                 br_occp_sum.burstprob.(ireg).(iband).(icond)(ifile,:) = spec_burst_occp.burstprob_avg.(icond).(iband);
%             end
%             br_occp_sum.burstprob_diff.(ireg).(iband)(ifile,:) = spec_burst_occp.burstprob_avg.high.(iband)-spec_burst_occp.burstprob_avg.low.(iband);
%             br_occp_sum.burstprob_ratio.(ireg).(iband)(ifile,:) = spec_burst_occp.burstprob_avg.high.(iband)./spec_burst_occp.burstprob_avg.low.(iband);
%         end
%         fprintf('>>> Completed %s: %.01f %% \n',ireg,ifile/numel(file_reg)*100);
%     end
    
    for iband = ["Beta","LowGamma","HighGamma"]
        for icond = ["high","low"]
            br_occp_sum.burstprob_avg.(ireg).(iband).(icond) = nanmean(br_occp_sum.burstprob.(ireg).(iband).(icond));
            br_occp_sum.burstprob_ste.(ireg).(iband).(icond) = nanstd(br_occp_sum.burstprob.(ireg).(iband).(icond))./sqrt(numel(file_reg));
        end
        br_occp_sum.burstprob_diff_avg.(ireg).(iband) = nanmean(br_occp_sum.burstprob_diff.(ireg).(iband));
        br_occp_sum.burstprob_diff_ste.(ireg).(iband) = nanstd(br_occp_sum.burstprob_diff.(ireg).(iband))./sqrt(numel(file_reg));
        ratios = br_occp_sum.burstprob_ratio.(ireg).(iband);
        ratios(~isfinite(ratios))=nan;
        br_occp_sum.burstprob_ratio_avg.(ireg).(iband) = nanmean(ratios);
        br_occp_sum.burstprob_ratio_ste.(ireg).(iband) = nanstd(ratios)./sqrt(numel(file_reg));
    end
end
br_occp_sum = ft_struct2single(br_occp_sum);
save(fullfile(outf,'br_occp_sum'),'br_occp_sum');

%% Plot difference & ratio
close all
fig = figure('Position',[0 0 1280 1600]);
freq = 2:128; time = -1:1/1000:4;
tlim = [-0.5,3.2]; flim = [2,100];
frng = freq>=flim(1)&freq<=flim(2); trng = time>=tlim(1)&time<=tlim(2);
tsel = time(trng); fsel = freq(frng);
gaus_win = 150;
grey = ones(1,3).*0.5;

for ipl = ["diff","ratio"]
    clf(fig,'reset');
    for ireg = ["PFC","VIP"]
        switch ireg
            case 'PFC'; x0 = 0.1;
            case 'VIP'; x0 = 0.57;
        end
        for iband = ["Beta","LowGamma","HighGamma"]
            switch iband
                case 'Beta'; y0 = 0.1; cb = 'b';
                case 'LowGamma'; y0 = 0.39; cb = 'r';
                case 'HighGamma'; y0 = 0.68; cb = 'g';
            end
            ax = axes(fig,'Position',[x0,y0,0.37,0.24]); hold on;
            
            avg = smoothdata(br_occp_sum.(strcat('burstprob_',ipl,'_avg')).(ireg).(iband),'gaussian',gaus_win);
            ste = smoothdata(br_occp_sum.(strcat('burstprob_',ipl,'_ste')).(ireg).(iband),'gaussian',gaus_win);
            l = plot(tsel,avg(trng),cb,'LineWidth',3);
            fill([tsel,fliplr(tsel)],[avg(trng)+ste(trng),fliplr(avg(trng)-ste(trng))],cb,'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
            xlim(tlim); yl = ylim();
            fill(ax,[0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill(ax,[1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill(ax,[3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            ylim(yl);
            
            if strcmp(iband,'Beta'); xlabel('Time to Sample Onset [s]'); end
            switch ipl
                case 'diff'; ylabel('Burst prob.: high-low');
                case 'ratio'; ylabel('Burst prob.: high/low');
            end
        end
        ax = axes(fig,'Position',[x0,0.1,0.37,0.83],'Visible','off');
        title(ireg,'FontSize',20,'Visible','on')
    end
    for iband = ["Beta","LowGamma","HighGamma"]
        switch iband
            case 'Beta'; y0 = 0.1; cb = 'b';
            case 'LowGamma'; y0 = 0.39; cb = 'r';
            case 'HighGamma'; y0 = 0.68; cb = 'g';
        end
        ax = axes(fig,'Position',[0.075,y0,0.8,0.22],'Visible','off');
        ylabel(iband,'FontSize',18,'Color',cb,'Visible','on');
    end
    
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    print(fullfile(outf,sprintf('brst_prob_by_ocp_%s',ipl)),'-depsc');
    print(fullfile(outf,sprintf('brst_prob_by_ocp_%s',ipl)),'-dpng');
end