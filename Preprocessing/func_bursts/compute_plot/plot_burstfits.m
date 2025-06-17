function plot_burstfits(channame)
specf = '/mnt/storage/xuanyu/MONKEY/Non-ion/2.Normalized_inclerror';
load(fullfile(specf,channame),'data_norm');
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(brstf,channame),'data_burst');
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/eg_trl';

irnd = 10;
ntrl = height(data_burst.trialinfo);
trls = randi(ntrl,irnd,1);

close all
fig = figure('Position',[0 0 400 300]);
for k = 1:irnd
    i = trls(k);
    clf(fig,'reset'); hold on;
    z = squeeze(data_norm.powspctrm_norm(i,:,:));
    imagesc(data_norm.time,data_norm.freq,z.*(z>=1.5)); % threshold at 1.5 SD
    
    bfit = data_burst.trialinfo.bursts{i};
    scatter(bfit.t,bfit.f,'MarkerFaceColor','r');
    arrayfun(@(x) filloval(bfit.t(x),bfit.f(x),bfit.t_sd(x),bfit.f_sd(x)), 1:size(bfit,1));
    
    set(gca,'YDir','normal');
    xlabel('Time from sample onset [s]')
    xlim([-0.5 3.5]);
    ylabel('freq [Hz]')
    ylim([4 100]);
    caxis([0 10]);
    colorbar
    arrayfun(@(x) line(ones(2,1)*x,ylim,'LineStyle','--'),[0 0.5 1.5 2 3]);
    title(sprintf('%s, trl-%d, thr = 1.5, + Daniel bursts',channame,i));
    
    print(gcf,fullfile(outf,sprintf('%s_%03d_Xuan',channame,i)),'-dpng');
end
end