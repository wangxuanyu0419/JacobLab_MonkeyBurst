% compute and plot time-resolved SFC between modules
clc; clear; close all;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_PFC2VIP_byepoch_byloc/SFC_sum','SFC_sum');
time = SFC_sum.time; freq = SFC_sum.freq;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_PFC2PFC_byepoch_byloc';
load(fullfile(inf,'SFC_sum'),'SFC_sum');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/SFC_interclust';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/T.mat','T');
%% Plot results
cl = [0 12e-3]; yl = [1,7];
close all; fig = figure('Position',[0 0 1200 800]);
for ianm = ["R","W"]
    clf(fig,'reset');
    n = T.(ianm).nclust;
    anmsel = cellfun(@(s) strcmp(s(1),ianm),SFC_sum.spkchan);
    ofdg = SFC_sum.spkloc~=SFC_sum.lfploc;
    for x = 1:n
        for y = 1:n
            subplot(n,n,x*n-n+y); hold on;
            data = cat(3,SFC_sum.ppc0{anmsel & SFC_sum.spklbl==x & SFC_sum.lfplbl==y & ofdg});
            m = mean(data,3,'omitnan');
            imagesc(time,log2(freq),m);
            set(gca,'YDir','normal');
            colormap(jet);
            arrayfun(@(x) plot(x*ones(1,2),yl,'--w'),[0,0.5,1.5,2,3,3.5]);
            ax = gca;
            ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
            xlim([-0.5,3.2]);
            ylabel('Frequency [Hz]'); yticks(1:7); yticklabels(2.^(1:7));
            ylim(yl);
            clim(cl);
            title(sprintf('#%d-->#%d, n = %d',x,y,size(data,3)));
            cb = colorbar; cb.Label.String = 'ppc';
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('PFC2PFC_SFC_byclust_%s_rmERP_rescale',ianm)),'-dpdf','-r0','-bestfit');
%     print(fullfile(outf,sprintf('PFC2PFC_SFC_byclust_%s_rmERP_rescale',ianm)),'-dpng');
    print(fullfile(outf,sprintf('PFC2PFC_SFC_byclust_%s_rmERP_rescale',ianm)),'-dpng');
end
%% Plot results, distance controlled
% compute distance
% load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/PEVspatial/PEVspt.mat');
SFC_sum.dist = zeros(height(SFC_sum),1);
for i = 1:height(SFC_sum)
    loc_spk = PEVspt.(SFC_sum.spkchan{i}(1)).loc_list(SFC_sum.spkloc(i),:);
    loc_lfp = PEVspt.(SFC_sum.spkchan{i}(1)).loc_list(SFC_sum.lfploc(i),:);
    SFC_sum.dist(i) = norm(loc_spk-loc_lfp);
end
save(fullfile(inf,'SFC_sum'),'SFC_sum');
%% plot results
cl = [0 15e-3]; yl = [1,7];
close all; fig = figure('Position',[0 0 1200 800]);
for ianm = ["R","W"]
    clf(fig,'reset');
    n = T.(ianm).nclust;
    anmsel = cellfun(@(s) strcmp(s(1),ianm),SFC_sum.spkchan);
    distsel = SFC_sum.dist>=3 & SFC_sum.dist<4;
    ofdg = SFC_sum.spkloc~=SFC_sum.lfploc;
    for x = 1:n
        for y = 1:n
            subplot(n,n,x*n-n+y); hold on;
            data = cat(3,SFC_sum.ppc0{anmsel & distsel & SFC_sum.spklbl==x & SFC_sum.lfplbl==y & ofdg});
            m = mean(data,3,'omitnan');
            imagesc(time,log2(freq),m);
            set(gca,'YDir','normal');
            colormap(jet);
            arrayfun(@(x) plot(x*ones(1,2),yl,'--w'),[0,0.5,1.5,2,3,3.5]);
            ax = gca;
            ax.YAxis.TickDirection = 'out'; ax.XAxis.TickDirection = 'out';
            xlim([-0.5,3.2]);
            ylabel('Frequency [Hz]'); yticks(1:7); yticklabels(2.^(1:7));
            ylim(yl);
            clim(cl);
            title(sprintf('#%d-->#%d, n = %d',x,y,size(data,3)));
            cb = colorbar; cb.Label.String = 'ppc';
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('PFC2PFC_SFC_byclust_d3_%s_rmERP_rescale',ianm)),'-dpdf','-r0','-bestfit');
%     print(fullfile(outf,sprintf('PFC2PFC_SFC_byclust_%s_rmERP_rescale',ianm)),'-dpng');
    print(fullfile(outf,sprintf('PFC2PFC_SFC_byclust_d3_%s_rmERP_rescale',ianm)),'-dpng');
end
