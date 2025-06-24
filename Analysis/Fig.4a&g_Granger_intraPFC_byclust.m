% plot granger causality (intra- and inter-regional) by PFC modules
clc; clear; close all;
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/26.connectivity';
load(fullfile(inf,'trialwise_grg','con_sum'),'con_sum');
load(fullfile(inf,'trialwise_grg','con_sort'),'con_sort');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/granger';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/6.BurstSeq/IBI/IBI_sum_chanpair','IBI_sum');
%% sort by distance and by cluster
edges = 0:15;
for ianm = ["R","W"]
    n = con_sort.(ianm).nclust;
    for icond = ["coherence","granger"]
        con_sort.(ianm).bydist.(icond).pool = cell(n,n,15);
    end
    % sort the data and pool across session
    for isess = 1:height(con_sum)
        if con_sum.sessions{isess}(1)~=ianm; continue; end
        lbl = con_sum.labels{isess};
        PFC = lbl~=0;
        for x = 1:n
            for y = 1:n
                xsel = lbl==x; ysel = lbl==y;
                if sum(xsel)*sum(ysel)==0; continue; end
                % get distance matrix
                dall = IBI_sum.sess.distance{isess};
                for icond = ["coherence","granger"]
                    data = con_sum.(icond){isess};
                    data = data(xsel,ysel,:);
                    data = reshape(data,[sum(xsel)*sum(ysel),length(freq)]);
                    dist = dall(xsel(PFC),ysel(PFC));
                    dist = reshape(dist,[sum(xsel)*sum(ysel),1]);
                    % bin by distance
                    xb = discretize(dist,edges);
                    for ib = 1:15
                        if ~ismember(ib,xb); continue; end
                        con_sort.(ianm).bydist.(icond).pool{x,y,ib}(end+(1:sum(xb==ib)),:) = data(xb==ib,:);
                    end
                end
            end
        end
    end
    for icond = ["coherence","granger"]
        for x = 1:n
            for y = 1:n
                for ib = 1:15
                    con_sort.(ianm).bydist.(icond).mean(x,y,ib,:) = mean(con_sort.(ianm).bydist.(icond).pool{x,y,ib},'omitnan');
                    con_sort.(ianm).bydist.(icond).npair(x,y,ib) = size(con_sort.(ianm).bydist.(icond).pool{x,y,ib},1);
                end
            end
        end
    end
end
save(fullfile(outf,'con_sort'),'con_sort');
%% Plot number of pairs for each distance and clustering condition. Granger
close all; fig = figure('Position',[0 0 200 600]);
for ianm = ["R","W"]
    clf(fig,'reset');
    n = con_sort.(ianm).nclust;
    for i = 1:12
        subplot(6,2,i);
        d = squeeze(con_sort.(ianm).bydist.granger.npair(:,:,i));
        imagesc(d./max(d(:))); colormap(redblue); clim([-1,1]);
        for x = 1:n
            for y = 1:n
                text(x,y,sprintf('%d',d(x,y)),'HorizontalAlignment','center');
            end
        end
        title(sprintf('d=%dmm',i-1))
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    print(fullfile(outf,sprintf('npair_bydist_%s',ianm)),'-dpng');
end
%% Plot intra-PFC, inter-cluster granger, distance controlled (d=3)
close all; fig = figure('Position',[0 0 300 300]);
fx = 5; fsel = freq>=(50-fx) & freq<=(50+fx);
c = [1 0 0; 0 1 0; 0 0 1; 1 1 0];
i = 4; % 3mm bin
for ianm = ["R","W"]
    n = con_sort.(ianm).nclust;
    clf(fig,'reset');
    hold on;
    for x = 1:n
        for y = 1:n
            if con_sort.(ianm).bydist.granger.npair(x,y,i)==0; continue; end
            if x~=y; lsty = '--'; else; lsty = '-'; end
            d = con_sort.(ianm).bydist.granger.pool{x,y,i};
            m = mean(d,'omitnan');
            m(fsel) = nan;
            xi = 1:numel(m);
            m(isnan(m)) = interp1(xi(~isnan(m)), m(~isnan(m)), xi(isnan(m)), 'linear');
            m = smoothdata(m,'gaussian',5);
            plot(log2(freq),m,lsty,'Color',(c(x,:).*0.7+c(y,:).*0.3),'DisplayName',sprintf('Clust#%d',x),'DisplayName',sprintf('%d-->%d',x,y));
        end
    end
    xlim([1,6]); xticks(1:6); xticklabels(2.^(1:6));
    ylabel('granger','FontSize',15);
    xlabel('Frequency [Hz]','FontSize',15)
    legend('boxoff');
    title(sprintf('%s, d = %d',ianm,i-1));
    set(gca,'TickDir','out');
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    print(fullfile(outf,sprintf('granger_bydist_d%d_%s',i-1,ianm)),'-dpng');
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('granger_bydist_d%d_%s',i-1,ianm)),'-dpdf','-r0','-bestfit');
end
%% Plot intra-PFC, R, #1-->#2 granger, d = 3
close all; fig = figure('Position',[0 0 300 300]);
fx = 5; fsel = freq>=(50-fx) & freq<=(50+fx);
c = [1 0 0; 0 1 0; 0 0 1; 1 1 0];
i = 4; % 3mm bin
ianm = "R";
hold on;
for x = 1:2
    for y = 1:2
        if con_sort.(ianm).bydist.granger.npair(x,y,i)==0; continue; end
        if x~=y; lsty = '--'; else; lsty = '-'; end
        d = con_sort.(ianm).bydist.granger.pool{x,y,i};
        m = mean(d,'omitnan');
        m(fsel) = nan;
        xi = 1:numel(m);
        m(isnan(m)) = interp1(xi(~isnan(m)), m(~isnan(m)), xi(isnan(m)), 'linear');
        m = smoothdata(m,'gaussian',5);
        plot(log2(freq),m,lsty,'Color',(c(x,:).*0.7+c(y,:).*0.3),'DisplayName',sprintf('Clust#%d',x),'DisplayName',sprintf('%d-->%d',x,y));
    end
end
xlim([1,6]); xticks(1:6); xticklabels(2.^(1:6));
ylabel('granger','FontSize',15);
xlabel('Frequency [Hz]','FontSize',15)
legend('boxoff');
title(sprintf('%s, d = %d',ianm,i-1));
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_bydist_d3_R_sel'),'-dpng');
set(gcf,'Renderer','painters');
print(fullfile(outf,'granger_bydist_d3_R_sel'),'-dpdf','-r0','-bestfit');
%% Plot bar plot, R, d=3, 2-8 Hz
freq = con_sort.freq; fsel = freq>=2&freq<8;
i = 4; % 3mm bin
ianm = "R";
m = []; e = []; name = cell(1,5);
ic =  1;
for x = 1:3
    for y = 1:3
        if con_sort.(ianm).bydist.granger.npair(x,y,i)==0; continue; end
        d = con_sort.(ianm).bydist.granger.pool{x,y,i};
        d = mean(d(:,fsel),2,'omitnan');
        m(ic) = mean(d,'omitnan');
        e(ic) = ste(d);
        name{ic} = sprintf('#%d-->#%d',x,y);
        ic = ic + 1;
    end
end
m = fliplr(m); e = fliplr(e); name = fliplr(name);
x = 1:length(m);
close all; fig = figure('Position',[0 0 300 150]); hold on;
bar(x,m); xticks(x); xticklabels(name);
errorbar(x,m,e,'k','LineStyle','none','LineWidth',0.5);
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_bydist_d3_R_sel'),'-dpng');
print(fullfile(outf,'granger_bydist_d3_R_sel'),'-dpdf','-r0');
%% Plot matrix, R, d=3, 2-8Hz
cord = [1,2;2,1;2,2;2,3;3,2;3,3];
mat = nan(3);
for i = 1:length(m)
    mat(cord(i,1),cord(i,2)) = m(i);
end
close all; fig = figure('Position',[0 0 120 100]);
heatmap(mat,'MissingDataColor',[0 0 0]);
colormap(viridis); colorbar;
clim([0,0.035]);
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_bydist_d3_R_mat'),'-dpng');
print(fullfile(outf,'granger_bydist_d3_R_mat'),'-dpdf','-r0');
%% Plot W, number of pairs for each distance and clustering condition.
close all; fig = figure('Position',[0 0 200 600]);
ianm = "W";
prj = {[1,2],[4],[3]};
cnt = nan(3,3,12);
for i = 1:12
    for x = 1:3
        src = prj{x};
        for y = 1:3
            tgt = prj{y};
            cnt(x,y,i) = sum(con_sort.(ianm).bydist.granger.npair(src,tgt,i),"all");
        end
    end
end
for i = 1:12
    subplot(6,2,i);
    d = squeeze(cnt(:,:,i));
    imagesc(d./max(d(:))); colormap(redblue); clim([-1,1]);
    for x = 1:3
        for y = 1:3
            text(x,y,sprintf('%d',d(x,y)),'HorizontalAlignment','center');
        end
    end
    title(sprintf('d=%dmm',i-1))
end
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,sprintf('npair_bydist_%s',ianm)),'-dpng');
%% Plot W, intra-PFC, inter-cluster granger, distance controlled (d=3)
close all; fig = figure('Position',[0 0 300 300]); hold on;
fx = 5; fsel = freq>=(50-fx) & freq<=(50+fx);
c = [1 0 0; 0 1 0; 0 0 1; 1 1 0];
i = 4; % 3mm bin
ianm = "W";
% recluster, merge clusters and regroup
data = cell(3);
for x = 1:3
    src = prj{x};
    for y = 1:3
        tgt = prj{y};
        if cnt(x,y,i)==0; continue; end
        if x~=y; lsty = '--'; else; lsty = '-'; end
        d = vertcat(con_sort.(ianm).bydist.granger.pool{src,tgt,i});
        m = mean(d,'omitnan');
        m(fsel) = nan;
        xi = 1:numel(m);
        m(isnan(m)) = interp1(xi(~isnan(m)), m(~isnan(m)), xi(isnan(m)), 'linear');
        m = smoothdata(m,'gaussian',5);
        plot(log2(freq),m,lsty,'Color',(c(x,:).*0.7+c(y,:).*0.3),'DisplayName',sprintf('Clust#%d',x),'DisplayName',sprintf('%d-->%d',x,y));
    end
end
xlim([1,6]); xticks(1:6); xticklabels(2.^(1:6));
ylabel('granger','FontSize',15);
xlabel('Frequency [Hz]','FontSize',15)
legend('boxoff');
title(sprintf('%s, d = %d',ianm,i-1));
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf,'Renderer','painters');
print(fullfile(outf,'granger_bydist_d3_W'),'-dpdf','-r0','-bestfit');
%% Plot W, d=3, 16-32Hz, bar&mat
freq = con_sort.freq; fsel = freq>=2&freq<8;
i = 4; % 3mm bin
ianm = "W";
m = []; e = []; name = cell(1,5);
ic =  1;
for x = 1:3
    src = prj{x};
    for y = 1:3
        tgt = prj{y};
        if cnt(x,y,i)==0; continue; end
        d = vertcat(con_sort.(ianm).bydist.granger.pool{src,tgt,i});
        d = mean(d(:,fsel),2,'omitnan');
        m(ic) = mean(d,'omitnan');
        e(ic) = ste(d);
        name{ic} = sprintf('#%d-->#%d',x,y);
        cord(ic,:) = [x,y];
        ic = ic + 1;
    end
end
m = fliplr(m); e = fliplr(e); name = fliplr(name);
x = 1:length(m);
% bar
close all; fig = figure('Position',[0 0 300 150]); hold on;
bar(x,m); xticks(x); xticklabels(name);
errorbar(x,m,e,'k','LineStyle','none','LineWidth',0.5);
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_bydist_d3_W_sel'),'-dpng');
print(fullfile(outf,'granger_bydist_d3_W_sel'),'-dpdf','-r0');
% mat
mat = nan(3);
for i = 1:length(m)
    mat(cord(i,1),cord(i,2)) = m(i);
end
close all; fig = figure('Position',[0 0 120 100]);
heatmap(mat,'MissingDataColor',[0 0 0]);
colormap(viridis); colorbar;
clim([0,0.015]);
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_bydist_d3_W_mat'),'-dpng');
print(fullfile(outf,'granger_bydist_d3_W_mat'),'-dpdf','-r0');
%% Plot results, pool across distance
close all; fig = figure('Position',[0 0 300 300]);
freq = con_sort.freq;
fx = 5; fsel = freq>=(50-fx) & freq<=(50+fx);
c = [1 0 0; 0 1 0; 0 0 1; 1 1 0];
i = 4; % 3mm bin
ianm = "R";
n = con_sort.(ianm).nclust;
clf(fig,'reset');
hold on;
for x = 1:n
    for y = 1:n
        if con_sort.(ianm).granger.npair(x,y)==0; continue; end
        if x~=y; lsty = '--'; else; lsty = '-'; end
        d = con_sort.(ianm).granger.pool{x,y};
        m = mean(d,'omitnan');
        m(fsel) = nan;
        xi = 1:numel(m);
        m(isnan(m)) = interp1(xi(~isnan(m)), m(~isnan(m)), xi(isnan(m)), 'linear');
        m = smoothdata(m,'gaussian',5);
        plot(log2(freq),m,lsty,'Color',(c(x,:).*0.7+c(y,:).*0.3),'DisplayName',sprintf('Clust#%d',x),'DisplayName',sprintf('%d-->%d',4-x,4-y));
    end
end
xlim([1,6]); xticks(1:6); xticklabels(2.^(1:6));
ylabel('granger','FontSize',15);
xlabel('Frequency (Hz)','FontSize',15)
legend('boxoff');
title(sprintf('%s, d = %d',ianm,i-1));
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,sprintf('granger_pool_%s',ianm)),'-dpng');
set(gcf,'Renderer','painters');
print(fullfile(outf,sprintf('granger_pool_%s',ianm)),'-dpdf','-r0','-bestfit');
%% Plot bar plot, R, d=3, 2-8 Hz
freq = con_sort.freq; fsel = freq>=2&freq<8;
ianm = "R";
m = []; e = []; name = cell(1,5);
ic =  1;
for x = 1:3
    for y = 1:3
        if con_sort.(ianm).granger.npair(x,y)==0; continue; end
        d = con_sort.(ianm).granger.pool{x,y};
        d = mean(d(:,fsel),2,'omitnan');
        m(ic) = mean(d,'omitnan');
        e(ic) = ste(d);
        name{ic} = sprintf('#%d-->#%d',4-x,4-y);
        ic = ic + 1;
    end
end
m = fliplr(m); e = fliplr(e); name = fliplr(name);
x = 1:length(m);
close all; fig = figure('Position',[0 0 300 150]); hold on;
bar(x,m); xticks(x); xticklabels(name);
errorbar(x,m,e,'k','LineStyle','none','LineWidth',0.5);
set(gca,'TickDir','out');
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_pool_R_sel'),'-dpng');
print(fullfile(outf,'granger_pool_R_sel'),'-dpdf','-r0');
% Plot matrix, R, d=3, 2-8Hz
cord = [1,1;1,2;2,1;2,2;2,3;3,2;3,3];
mat = nan(3);
for i = 1:length(m)
    mat(cord(i,1),cord(i,2)) = m(i);
end
close all; fig = figure('Position',[0 0 120 100]);
heatmap(mat,'MissingDataColor',[0 0 0]);
colormap(viridis); colorbar;
clim([0,0.035]);
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
print(fullfile(outf,'granger_pool_R_mat'),'-dpng');
print(fullfile(outf,'granger_pool_R_mat'),'-dpdf','-r0');