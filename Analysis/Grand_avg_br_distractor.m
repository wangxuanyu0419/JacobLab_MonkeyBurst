% plot distractor induced differences, use a different time axis
close all; clear;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand/data_sum.mat','data_sum');
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';

PFC_idx = cellfun(@(s) strcmp(s,'PFC'),data_sum.Region);
cband = {[248 195 38],[129 189 92],[39 168 224]};
Bands = ["Beta","LowGamma","HighGamma"]; yrng = {[15 35], [35 60], [60 90]};
gaus_win = 150;
tlim = [1,3.2]; time = data_sum.time;
trng = time>=tlim(1) & time<=tlim(2); time_sel = time(trng);
grey = ones(1,3).*0.5;

% Compute gliding-window Wilcoxon:
win = 200/1000;
alpha95 = 0.05;
alpha99 = 0.01;
step = 20;
t_ds = downsample(time_sel,step);

fig = figure('Position',[0 0 900 300], 'Visible', true);
for ireg = ["PFC","VIP"]
	switch ireg
		case 'PFC'; x0 = 0.12; reg_list = PFC_idx;
		case 'VIP'; x0 = 0.57; reg_list = ~PFC_idx;
	end
	ax = axes(fig,'Position', [x0, 0.1, 0.37 0.8]); % figure window
	hold on;
	fill(ax,[0 0.5 0.5 0],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
	fill(ax,[1.5 2 2 1.5],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
	fill(ax,[3 3.5 3.5 3],[1 1 -1 -1],grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
	ib = 0;
	for iband = Bands
		ib = ib+1;
		data1 = data_sum.(iband)(reg_list,trng);
		data2 = data_sum.nodist.(iband)(reg_list,trng);
		data_sel = data1-data2;
		data_avg = nanmean(data_sel);
		data_ste = nanstd(data_sel,0,1)./sqrt(size(data_sel,1));
		data_avg = smoothdata(data_avg,'gaussian',gaus_win);
		data_ste = smoothdata(data_ste,'gaussian',gaus_win);
		data_erb = [data_avg-data_ste, fliplr(data_avg+data_ste)];
%		fill([time_sel,fliplr(time_sel)],data_erb,cband{ib},'FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
		% Compute stats
		switch iband
		case 'HighGamma'; yb = 0.125;
		case 'LowGamma'; yb = 0.12;
		case 'Beta'; yb = 0.115;
		end
		p = arrayfun(@(ti) signrank(nanmean(data1(:,time_sel>=(ti-win/2)&time_sel<=(ti+win/2)),2),nanmean(data2(:,time_sel>=(ti-win/2)&time_sel<=(ti+win/2)),2)),t_ds);
		plot(time_sel,data_avg,'Color',cband{ib}./255,'LineWidth',1,'DisplayName',iband);
		scatter(t_ds(p<alpha95)',yb*ones(sum(p<alpha95),1),30,repmat(cband{ib}/255,sum(p<alpha95),1),'.','HandleVisibility','off');
		scatter(t_ds(p<alpha99)',yb*ones(sum(p<alpha99),1),80,repmat(cband{ib}/255,sum(p<alpha99),1),'.','HandleVisibility','off');

		xlim(tlim); ylim([-0.03,0.13]);
		xlabel('Time from Sample Onset [s]','FontSize',12);
		ylabel('\Delta Burst Probability','FontSize',12);
		legend('boxoff');
		set(gca,'TickDir','out');
	end
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(fig,'Renderer','Painters'); % avoid printing bitmaps
print(fullfile(outfigf,'GrandAvg_BR_region_diffdist'),'-depsc')
print(fullfile(outfigf,'GrandAvg_BR_region_diffdist'),'-dpng')
print(fullfile(outfigf,'GrandAvg_BR_region_diffdist'),'-dpdf','-r0','-bestfit')

