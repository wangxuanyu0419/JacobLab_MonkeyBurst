close all
clear all

f = dir('/mnt/storage2/xuanyu/MONKEY/Non-ion/2.Normalized/*.mat');
f = f(arrayfun(@(x) ismember(x.name(1:12),{'R120516-AD01' 'R120516-AD09' 'R120516-AD10' 'R120516-AD11'}),f));
fx = dir('/mnt/storage2/xuanyu/MONKEY/Non-ion/3.Bursts/*.mat');
fx = fx(arrayfun(@(x) ismember(x.name(1:12),{'R120516-AD01' 'R120516-AD09' 'R120516-AD10' 'R120516-AD11'}),fx));

for i = 1:numel(f)
    load(fullfile(f(i).folder,f(i).name)); % load data_norm
    load(fullfile(fx(i).folder,fx(i).name)); % loaddata_burst
    for j = [19 20 21] % example trials 16 17 18
        fig = figure('Position',[900 -994 1280 723]);
        hold on
        trl = j-3;
        z = squeeze(data_norm.powspctrm_norm(trl,:,:));
        imagesc(data_norm.time,data_norm.freq,z.*(z>=1.5)); % threshold at 1.5 SD
        
        bfit = data_burst.trialinfo.bursts{trl,1};
        scatter(bfit.t,bfit.f,'MarkerFaceColor','r');
        arrayfun(@(x) filloval(bfit.t(x),bfit.f(x),bfit.t_sd(x),bfit.f_sd(x)), 1:size(bfit,1));
        
        
        set(gca,'YDir','normal');
        xlabel('time from sample presentation [s]')
        xlim([-0.5 3.5]);
        ylabel('freq [Hz]')
        ylim([4 100]);
        caxis([0 10]);
        colorbar
        arrayfun(@(x) line(ones(2,1)*x,ylim,'LineStyle','--'),[0 0.5 1.5 2 3]);
        title(sprintf('Trial %d, threshold 1.5, sess %s, Channel %s, plotted against Daniel bursts',trl,f(i).name(1:7),f(i).name(9:12)));

        print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/3.Bursts',sprintf('%s_%03d_Xuan',f(i).name(1:12),trl)),'-dpng');
        close all
    end
end
