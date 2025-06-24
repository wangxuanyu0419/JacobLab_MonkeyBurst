% Plot burst rate by location
clc; clear; close all;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';
load(fullfile(inf,'AvgBrstSpatial'),'AvgBrstSpatial');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs/Grand_avg_clust';
%% Plot by location
t = -1:1e-3:4;
trng = [-0.5,3.2];
tsel = t>=trng(1)&t<trng(2);
time = t(tsel);
yl = [0,0.4];
grey = ones(1,3).*0.5;
for ianm = ["R","W"]
    tl = sprintf('Monkey %s, average BPF with layout',ianm);
    close all; ax = plot_inset_byloc(ianm,tl);
    for ich = 1:size(AvgBrstSpatial.(ianm).loc_list,1)
        axes(ax(ich));
        fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        plot(time,AvgBrstSpatial.(ianm).HighGamma_avg(ich,tsel),'LineWidth',1,'Color','b');
        plot(time,AvgBrstSpatial.(ianm).Beta_avg(ich,tsel),'LineWidth',1,'Color','r');
        ylim(yl); xlim(trng);
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('GrandAvg_BR_byloc_%s',ianm)),'-dpng');
    set(gcf,'PaperOrientation','landscape');
    print(fullfile(outf,sprintf('GrandAvg_BR_byloc_%s',ianm)),'-dpdf','-r0','-bestfit');
end