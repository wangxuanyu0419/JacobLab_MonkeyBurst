% perform PCA on BR of Gamma and Beta bands for two monkeys, take
% trial-average covariance matrix
clear; clc; close all;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/dPCA/BrstSumMat.mat','mat');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat';
inf = '/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial';
load(fullfile(inf,'AvgBrstSpatial'),'AvgBrstSpatial');
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/PEVspatial/PEVspt.mat','PEVspt');
%%
t = -1:1e-3:4;
trng = [-0.5,3.2]; t1rng = [0,0.2]; t0rng = [-0.5,0];
tsel = t>=trng(1)&t<trng(2);
time = t(tsel);
t1 = time>=t1rng(1)&time<t1rng(2);
t0 = time>=t0rng(1)&time<t0rng(2);
grey = ones(1,3).*0.5;
close all; fig = figure('Position',[0 0 1000 800]);
for ianm = ["R","W"]
    for iband = ["Gamma","Beta"]
        clf(fig,'reset');
        Xs = mean(mat.(ianm).(iband)(:,:,:,tsel,:),5,'omitnan'); % take channel average
        m = squeeze(mean(Xs,[2 3],'omitnan'));
        for isamp = 1:4
            for idist = 1:4
                x = squeeze(Xs(:,isamp,idist,:));
                x = bsxfun(@minus, x, mean(x,2));
                covcell{isamp,idist} = x*x'./(size(x,2)-1);
            end
        end
        covmat = cat(3,covcell{:}); covmat = squeeze(mean(covmat,3));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % plot covariance matrix
        cl = [0,max(covmat(eye(size(covmat,1))==0))];
        subplot(541);  colormap(gray);
        imagesc(covmat);
        clim(cl); colorbar;
        ylabel('Covariance of condition avg');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % perform PCA
        [W,S,~] = svd(covmat); % W: eigenvector matrix, each row is component loading
        eigval = diag(S);
        expvar = eigval./sum(eigval)*100;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % plot explained variance
        subplot(545);
        plot(1:size(W,2),cumsum(expvar),'-o','Color','k')
        ylim([0 100]); ylabel('Exp. Var.');
        xlabel('# of components');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % plot components
        for i = 1:5
            w = W(:,i);
            mxg = w'*m;
            % plot loading
            subplot(5,4,4*i-2);
            cmap = colormap(gca,redblue);
            h = plot_dot_byloc(gca,ianm,sprintf('#%d PCA loading',i));
            if mean(mxg(t1))<mean(mxg(t0)); w = -w; mxg = -mxg; end
            [cl(1),cl(2)] = bounds(w);
            cl = max(abs(cl)).*[-1,1];
            colorbar; clim(cl);
            zscl = linspace(cl(1),cl(2),size(cmap,1));
            for ich = 1:numel(h)
                d = w(ich);
                [~,zx] = min(abs(zscl-d));
                h{ich}.FaceColor = cmap(zx,:);
            end
            xticks([]); yticks([]);
            % plot component burst rate
            subplot(5,4,4*i+[-1,0]); hold on;
            plot(time,mxg,'k');
            yl = ylim();
            fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            ylim(yl); ylabel('Friring rate');
            xlim(trng); % xlabel('Time from sample onset [s]');
            title(sprintf('Explained variance = %.01f%%',expvar(i)))
        end
        set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
        set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
        set(gcf,'Renderer','painters');
        print(fullfile(outf,sprintf('PCA_BR_avgcovmat_%s_%s',ianm,iband)),'-dpng');
        print(fullfile(outf,sprintf('PCA_BR_avgcovmat_%s_%s',ianm,iband)),'-dpdf','-r0','-bestfit');
    end
end
%% perform PCA, mean covariance matrix across both Gamma and Beta
close all; fig = figure('Position',[0 0 1920 1080]);
clear m covcell;
for ianm = ["R","W"]
    clf(fig,'reset');
    for iband = ["Gamma","Beta"]
        [~,ib] = ismember(iband,["Gamma","Beta"]);
        Xs = mean(mat.(ianm).(iband)(:,:,:,tsel,:),5,'omitnan'); % take channel average
        m.(iband) = squeeze(mean(Xs,[2 3],'omitnan'));
        for isamp = 1:4
            for idist = 1:4
                x = squeeze(Xs(:,isamp,idist,:));
                x = bsxfun(@minus, x, mean(x,2));
                covcell{ib,isamp,idist} = x*x'./(size(x,2)-1);
            end
        end
    end
    covmat = cat(3,covcell{:}); covmat = squeeze(mean(covmat,3));
    res.(ianm).covmat = covmat;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot covariance matrix
    cl = [0,max(covmat(eye(size(covmat,1))==0))];
    subplot(561);  colormap(gray);
    imagesc(covmat);
    clim(cl); colorbar;
    ylabel('Covariance of condition avg');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % perform PCA
    [W,S,~] = svd(covmat); % W: eigenvector matrix, each row is component loading
    res.(ianm).weight = W;
    eigval = diag(S);
    expvar = eigval./sum(eigval)*100;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot explained variance
    subplot(567);
    plot(1:size(W,2),cumsum(expvar),'-o','Color','k')
    ylim([0 100]); ylabel('Exp. Var.');
    xlabel('# of components');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot components
    for i = 1:5
        w = W(:,i);
        mxg = w'*m.Gamma;
        mxb = w'*m.Beta;
        % plot loading
        subplot(5,6,6*i-4);
        cmap = colormap(gca,redblue);
        h = plot_dot_byloc(gca,ianm,sprintf('#%d PCA loading',i));
        if mean(mxg(t1))<mean(mxg(t0)); w = -w; mxg = -mxg; mxb = -mxb; end
        [cl(1),cl(2)] = bounds(w);
        cl = max(abs(cl)).*[-1,1];
        colorbar; clim(cl);
        zscl = linspace(cl(1),cl(2),size(cmap,1));
        for ich = 1:numel(h)
            d = w(ich);
            [~,zx] = min(abs(zscl-d));
            h{ich}.FaceColor = cmap(zx,:);
        end
        xticks([]); yticks([]);
        % plot component burst rate: Gamma
        for iband = ["Gamma","Beta"]
            switch iband
                case 'Gamma'
                    subplot(5,6,6*i+[-3,-2]); hold on;
                    plot(time,mxg,'Color','b');
                    title(sprintf('Explained variance = %.01f%%',expvar(i)))
                    ylabel('Gamma FR');
                case 'Beta'
                    subplot(5,6,6*i+[-1,0]); hold on;
                    plot(time,mxb,'Color','r');
                    ylabel('Beta FR');
            end
            yl = ylim();
            fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            ylim(yl);
            xlim(trng); % xlabel('Time from sample onset [s]');
            set(gca,'TickDir','out');
        end
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf,'Renderer','painters');
%     print(fullfile(outf,sprintf('PCA_BR_avgcovmat_%s_twobands',ianm)),'-dpng');
%     print(fullfile(outf,sprintf('PCA_BR_avgcovmat_%s_twobands',ianm)),'-dpdf','-r0','-bestfit');
end
save(fullfile(outf,'res'),'res');
%% perform hierarchical clustering on the covariance matrix
cutoff = 1; cb = 'br';
close all; fig = figure('Position',[0 0 1920 1000]);
% cmap = [0.5 0 1; 0.5 1 0; 0 1 1; 1 0 0];
for ianm = ["R","W"]
    switch ianm
        case 'R'; nclust = 3;
        case 'W'; nclust = 3; % or 4
    end
    clf(fig,'reset');
    covmat = res.(ianm).covmat;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot covariance matrix, unsorted
    cl = [0,max(covmat(eye(size(covmat,1))==0))];
    subplot(4,8,1);  colormap(gray);
    imagesc(covmat);
    clim(cl); %colorbar;
    title('Covariance matrix unsorted');
    xticks([]); yticks([]);
    % perform hierarchical clustering
    Z = linkage(covmat,'complete','correlation');
    xl = xlim();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot covariance matrix, unsorted
    subplot(4,8,9);
%     T = cluster(Z,'cutoff',cutoff,'Criterion','distance');
    Tl = cluster(Z,'maxclust',nclust);
    T.(ianm).lbl = Tl;
    T.(ianm).nclust = nclust;
%     [H,~,outperm] = dendrogram(Z,0,'colorthreshold',cutoff);
    [H,~,outperm] = dendrogram(Z);
    for ih = 1:numel(H)
        H(ih).Color = 'k';
    end
%     cmap = unique(vertcat(H.Color),"rows",'stable');
%     cmap = cmap(1:end-1,:);
%     hold on; plot(xl,cutoff*[1 1],'--k');
    set(gca,'FontSize',5)
    title('Dendrogram tree','FontSize',10);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot sorted covmat
    subplot(4,8,17);
    covmat_s = covmat(outperm,outperm);
    colormap(gray);
    imagesc(covmat_s);
    clim(cl); %colorbar;
    xticks([]); yticks([]);
    title('Covariance matrix sorted');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot spatial distribution of the labelings
    subplot(4,8,25);
    cmap = colormap(gca,hsv(length(unique(Tl))));
    h = plot_dot_byloc(gca,ianm,'Labeling');
    xticks([]); yticks([]);
    for iloc = 1:numel(h)
        locs = AvgBrstSpatial.(ianm).loc_list(iloc,:);
        h{iloc}.FaceColor = cmap(Tl(iloc),:);
        text(locs(1),locs(2),num2str(iloc),'HorizontalAlignment','center','FontSize',5);
    end
    for i = 1:max(Tl)
        subplot(4,8,8*i-6);
        h = plot_dot_byloc(gca,ianm,sprintf('#%d',i));
        for iloc = 1:numel(h)
            if Tl(iloc)==i; h{iloc}.FaceColor = cmap(i,:); end
        end
        xticks([]); yticks([]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot mean Gamma and Beta rate in selected clusters
    [~,loc_id] = cellfun(@(x) ismember(x,AvgBrstSpatial.(ianm).loc_list,'rows'),AvgBrstSpatial.(ianm).location);
    nch = arrayfun(@(i) sum(loc_id==i),1:size(AvgBrstSpatial.(ianm).loc_list,1));
    [~,locproj] = ismember(PEVspt.(ianm).loc_list,AvgBrstSpatial.(ianm).loc_list,'rows');
    Tspk = Tl(locproj);
    for i = 1:max(Tl)
        for iband = ["Gamma","Beta"]
            [~,ib] = ismember(iband,["Gamma","Beta"]);
            switch iband
                case 'Gamma'; d = AvgBrstSpatial.(ianm).HighGamma_avg(Tl==i,:);
                case 'Beta'; d = AvgBrstSpatial.(ianm).Beta_avg(Tl==i,:);
            end
            % plot mean burst rate
            subplot(4,8,i*8-8+2*ib+[1,2]); hold on;
            plot(time,mean(d(:,tsel),'omitnan'),'k');
            yl = ylim();
            fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
            ylim(yl);
            xlim(trng); % xlabel('Time from sample onset [s]');
            set(gca,'TickDir','out');
            title(sprintf('%s,n=%d',iband,sum(nch(Tl==i))),'Color',cb(ib));
        end
        % plot mean PEV
        subplot(4,8,i*8-2+[1,2]); hold on;
        samp = PEVspt.(ianm).samp_avg(Tspk==i,:);
        dist = PEVspt.(ianm).dist_avg(Tspk==i,:);
        plot(PEVspt.tds,mean(samp,'omitnan'),'c');
        fill([PEVspt.tds,fliplr(PEVspt.tds)],[mean(samp,'omitnan')+ste(samp),fliplr(mean(samp,'omitnan')-ste(samp))],'c','EdgeColor','none','FaceAlpha',0.3);
        plot(PEVspt.tds,mean(dist,'omitnan'),'m');
        fill([PEVspt.tds,fliplr(PEVspt.tds)],[mean(dist,'omitnan')+ste(dist),fliplr(mean(dist,'omitnan')-ste(dist))],'m','EdgeColor','none','FaceAlpha',0.3);
        yl = ylim();
        fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        ylim(yl);
        xlim(trng); % xlabel('Time from sample onset [s]');
        set(gca,'TickDir','out');
        title(sprintf('MUA, n=%d',sum(PEVspt.(ianm).nch(Tspk==i))));
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('PCA_BR_avgcovmat_%s_twobands_nclust%d',ianm,nclust)),'-dpng');
    print(fullfile(outf,sprintf('PCA_BR_avgcovmat_%s_twobands_nclust%d',ianm,nclust)),'-dpdf','-r0','-bestfit');
end
save(fullfile(outf,'T'),'T');
%% label each site with the maximum (absolute) loading
close all; fig = figure('Position',[0 0 800 800]);
cmap = lines(5);
for ianm = ["R","W"]
    axes(fig);
    h = plot_dot_byloc(gca,ianm,'#PC');
    % get labeling
    W = res.(ianm).weight(:,1:3);
    % revert component 1 and 3 for R
    W(:,[1,3]) = -W(:,[1,3]);
    [~,i] = max(W,[],2);
    for iloc = 1:numel(h)
        locs = AvgBrstSpatial.(ianm).loc_list(iloc,:);
        h{iloc}.FaceColor = cmap(i(iloc),:);
        text(locs(1),locs(2),num2str(sign(W(iloc,i(iloc)))*i(iloc)),'HorizontalAlignment','center');
    end
end