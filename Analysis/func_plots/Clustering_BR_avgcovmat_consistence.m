% compute classifying consistency by band and location, split-half used
clc; clear; close all;
niter = 100;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/14.OCPspatial/AvgBrstSpatial/AvgBrstSpatial','AvgBrstSpatial');
chans = AvgBrstSpatial.files;
% folder with BPFs
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/Consist';
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/25.ObjClust/Consist/PermBPF'; % mkdir(inf);
% example channel
% get_burst_rate_splthf(chans{1},niter);
% pipeline
delete(gcp('nocreate')); parpool(32);
parfor ichan = 1:numel(chans)
    get_burst_rate_splthf(chans{ichan},niter);
    fprintf('>>> Completed %s\n',chans{ichan});
end
%% Get summary and sort by location
BPF_perm = struct();
BPF_perm.files = AvgBrstSpatial.files;
BPF_perm.location = AvgBrstSpatial.location;
for iband = ["HighGamma","Beta"]
    BPF_perm.(iband) = cell(numel(BPF_perm.files),niter,4,4,2);
end
prog = 0.0;
fprintf('>>> Loading completed %3.0f%%\n',prog)
for ichan = 1:numel(chans)
    load(fullfile(inf,chans{ichan}),'burst_rate');
    for iband = ["HighGamma","Beta"]
        BPF_perm.(iband)(ichan,:,:,:,:) = burst_rate.(iband);
    end
    prog = ichan/numel(chans)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
for ianm = ["R","W"]
    BPF_perm.(ianm) = struct();
    BPF_perm.(ianm).files = AvgBrstSpatial.(ianm).files;
    BPF_perm.(ianm).location = AvgBrstSpatial.(ianm).location;
    anm_list = cellfun(@(s) strcmp(s(1),ianm),AvgBrstSpatial.files);
    [loc,~,idx] = unique(vertcat(BPF_perm.(ianm).location{:}),'row');
    BPF_perm.(ianm).loc_list = loc;
    for iband = ["HighGamma","Beta"]
        data = BPF_perm.(iband)(anm_list,:,:,:,:);
        BPF_perm.(ianm).(iband) = nan(size(loc,1),niter,4,4,2,length(data{1}));
        for il = 1:size(loc,1)
            for iter = 1:niter
                for isamp = 1:4
                    for idist = 1:4
                        for ihf = 1:2
                            BPF_perm.(ianm).(iband)(il,iter,isamp,idist,ihf,:) = mean(vertcat(data{idx==il,iter,isamp,idist,ihf}),'omitnan');
                        end
                    end
                end
            end
        end
    end
end
BPF_perm = rmfield(BPF_perm,{'HighGamma','Beta'}); % remove the unsorted fields
%% perform clustering with split-half permutated data
t = -1:1e-3:4;
trng = [-0.5,3.2];
tsel = t>=trng(1)&t<trng(2);
time = t(tsel);
for nclust = 2:5
    s = sprintf('nc%d',nclust);
    for ianm = ["R","W"]
%         BPF_perm.(ianm).(s) = struct();
%         for iband = ["HighGamma","Beta"]
%             BPF_perm.(ianm).(s).(iband).Z = cell(iter,2);
%             BPF_perm.(ianm).(s).(iband).T = nan(iter,2,size(BPF_perm.(ianm).loc_list,1));
%             prog = 0.0;
%             fprintf('>>> Computing monkey %s, nclust=%d, %s band: %3.0f%%\n',ianm,nclust,iband,prog);
%             for iter = 1:niter
%                 for ihf = 1:2
%                     % compute covariance matrix
%                     covcell = cell(4);
%                     for isamp = 1:4
%                         for idist = 1:4
%                             x = squeeze(BPF_perm.(ianm).(iband)(:,iter,isamp,idist,ihf,tsel));% nloc x (niter x samp x dist x halves) x tsel matrix
%                             x = bsxfun(@minus, x, mean(x,2));
%                             covcell{isamp,idist} = x*x'./(size(x,2)-1);
%                         end
%                     end
%                     covmat = cat(3,covcell{:}); covmat = squeeze(mean(covmat,3));
%                     % perform clustering
%                     Z = linkage(covmat,'complete','correlation');
%                     T = cluster(Z,'MaxClust',nclust);
%                     BPF_perm.(ianm).(s).(iband).Z{iter,ihf} = Z;
%                     BPF_perm.(ianm).(s).(iband).T(iter,ihf,:) = T;
%                 end
%                 prog = iter/niter*100;
%                 fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
%             end
%         end
        % when combining both bands
        BPF_perm.(ianm).(s).Both.Z = cell(iter,2);
        BPF_perm.(ianm).(s).Both.T = nan(iter,2,size(BPF_perm.(ianm).loc_list,1));
        prog = 0.0;
        fprintf('>>> Computing monkey %s, nclust=%d, both bands: %3.0f%%\n',ianm,nclust,prog);
        for iter = 1:niter
            for ihf = 1:2
                for iband = ["HighGamma","Beta"]
                    % compute covariance matrix
                    covcell = cell(4);
                    for isamp = 1:4
                        for idist = 1:4
                            x = squeeze(BPF_perm.(ianm).(iband)(:,iter,isamp,idist,ihf,tsel));% nloc x (niter x samp x dist x halves) x tsel matrix
                            x = bsxfun(@minus, x, mean(x,2));
                            covcell{isamp,idist} = x*x'./(size(x,2)-1);
                        end
                    end
                    covmat = cat(3,covcell{:}); covmat_band.(iband) = squeeze(mean(covmat,3));
                end
                covmat = cat(3,covmat_band.HighGamma,covmat_band.Beta);
                covmat = squeeze(mean(covmat,3));
                % perform clustering
                Z = linkage(covmat,'complete','correlation');
                T = cluster(Z,'MaxClust',nclust);
                BPF_perm.(ianm).(s).Both.Z{iter,ihf} = Z;
                BPF_perm.(ianm).(s).Both.T(iter,ihf,:) = T;
            end
            prog = iter/niter*100;
            fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
        end
    end
end
save(fullfile(outf,'BPF_perm'),'BPF_perm','-v7.3');
%% Perform permutation test to get a null hypothesis
nshf = 10;
% popularate the burst rates again.
for iband = ["HighGamma","Beta"]
    BPF_perm.(iband) = cell(numel(BPF_perm.files),niter,4,4,2);
end
prog = 0.0;
fprintf('>>> Loading completed %3.0f%%\n',prog)
for ichan = 1:numel(chans)
    load(fullfile(inf,chans{ichan}),'burst_rate');
    for iband = ["HighGamma","Beta"]
        BPF_perm.(iband)(ichan,:,:,:,:) = burst_rate.(iband); % nchan x 
    end
    prog = ichan/numel(chans)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end

% calculate location-shuffled results.
for ianm = ["R","W"]
    anm_list = cellfun(@(s) strcmp(s(1),ianm),AvgBrstSpatial.files);
    [loc,~,idx] = unique(vertcat(BPF_perm.(ianm).location{:}),'row');
    for iband = ["HighGamma","Beta"]
        data = BPF_perm.(iband)(anm_list,:,:,:,:);
        BPF_perm.(ianm).(strcat(iband,'_shuffle')) = nan(size(loc,1),niter,nshf,4,4,2,length(data{1}));
        for il = 1:size(loc,1)
            for iter = 1:niter % take every splithalf samples
                % perform shuffleing for 10 times for each splithalf
                for ishf = 1:nshf
                    idx_shf = idx(randperm(length(idx)));
                    for isamp = 1:4
                        for idist = 1:4
                            for ihf = 1:2
                                BPF_perm.(ianm).(strcat(iband,'_shuffle'))(il,iter,ishf,isamp,idist,ihf,:) = mean(vertcat(data{idx_shf==il,iter,isamp,idist,ihf}),'omitnan');
                            end
                        end
                    end
                end
            end
        end
    end
end

% summarize shuffled results, calculate the splithalf reliability.
for nclust = 2:5
    s = sprintf('nc%d_perm',nclust);
    for ianm = ["R","W"]
        BPF_perm.(ianm).(s) = struct();
        for iband = ["HighGamma","Beta"]
            BPF_perm.(ianm).(s).(iband).Z = cell(niter*nshf,2);
            BPF_perm.(ianm).(s).(iband).T = nan(niter*nshf,2,size(BPF_perm.(ianm).loc_list,1));
            prog = 0.0;
            fprintf('>>> Computing monkey %s, nclust=%d, %s band: %3.0f%%\n',ianm,nclust,iband,prog);
            for iter = 1:niter
                for ishf = 1:nshf
                    idx = (iter-1)*nshf+ishf;
                    for ihf = 1:2
                        % compute covariance matrix
                        covcell = cell(4);
                        for isamp = 1:4
                            for idist = 1:4
                                x = squeeze(BPF_perm.(ianm).(strcat(iband,'_shuffle'))(:,iter,ishf,isamp,idist,ihf,tsel));% nloc x (niter x nshf x samp x dist x halves) x tsel matrix
                                x = bsxfun(@minus, x, mean(x,2));
                                covcell{isamp,idist} = x*x'./(size(x,2)-1);
                            end
                        end
                        covmat = cat(3,covcell{:}); covmat = squeeze(mean(covmat,3));
                        % perform clustering
                        Z = linkage(covmat,'complete','correlation');
                        T = cluster(Z,'MaxClust',nclust);
                        BPF_perm.(ianm).(s).(iband).Z{idx,ihf} = Z;
                        BPF_perm.(ianm).(s).(iband).T(idx,ihf,:) = T;
                    end
                    prog = idx/nshf/niter*100;
                    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
                end
            end
        end
        % when combining both bands
        BPF_perm.(ianm).(s).Both.Z = cell(iter,2);
        BPF_perm.(ianm).(s).Both.T = nan(iter,2,size(BPF_perm.(ianm).loc_list,1));
        prog = 0.0;
        fprintf('>>> Computing monkey %s, nclust=%d, both bands: %3.0f%%\n',ianm,nclust,prog);
        for iter = 1:niter
            for ishf = 1:nshf
                idx = (iter-1)*nshf+ishf;
                for ihf = 1:2
                    for iband = ["HighGamma","Beta"]
                        % compute covariance matrix
                        covcell = cell(4);
                        for isamp = 1:4
                            for idist = 1:4
                                x = squeeze(BPF_perm.(ianm).(strcat(iband,'_shuffle'))(:,iter,ishf,isamp,idist,ihf,tsel));% nloc x (niter x samp x dist x halves) x tsel matrix
                                x = bsxfun(@minus, x, mean(x,2));
                                covcell{isamp,idist} = x*x'./(size(x,2)-1);
                            end
                        end
                        covmat = cat(3,covcell{:}); covmat_band.(iband) = squeeze(mean(covmat,3));
                    end
                    covmat = cat(3,covmat_band.HighGamma,covmat_band.Beta);
                    covmat = squeeze(mean(covmat,3));
                    % perform clustering
                    Z = linkage(covmat,'complete','correlation');
                    T = cluster(Z,'MaxClust',nclust);
                    BPF_perm.(ianm).(s).Both.Z{idx,ihf} = Z;
                    BPF_perm.(ianm).(s).Both.T(idx,ihf,:) = T;
                end
            end
            prog = iter/niter*100;
            fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
        end
    end
end
BPF_perm = rmfield(BPF_perm,{'HighGamma','Beta'}); % remove the unsorted fields
% BPF_perm.R = rmfield(BPF_perm.R,{'HighGamma','Beta','HighGamma_shuffle','Beta_shuffle'});
% BPF_perm.W = rmfield(BPF_perm.W,{'HighGamma','Beta','HighGamma_shuffle','Beta_shuffle'});
save(fullfile(outf,'BPF_perm'),'BPF_perm','-v7.3');
%% Plot results: decay function of classfication consistency, by location, pool across iterations
close all; fig = figure('Position',[0 0 1000 600]);
for ianm = ["R","W"]
    clf(fig,'reset');
    for iband = ["HighGamma","Beta","Both"]
        [~,ib] = ismember(iband,["HighGamma","Beta","Both"]);
        % decay function
        cons = nan(5,size(BPF_perm.(ianm).loc_list,1));
        cons(1,:) = 1;
        for nclust = 2:5
            for il = 1:size(BPF_perm.(ianm).loc_list,1)
                T = BPF_perm.(ianm).(sprintf('nc%d',nclust)).(iband).T(:,:,il);
                c = T(:,1)==T(:,2);
                cons(nclust,il) = mean(c);
            end
        end
        % shuffled baseline
        perm_m = nan(1,4);
        perm_95 = nan(1,4);
        for nclust = 2:5
            T = BPF_perm.(ianm).(sprintf('nc%d_perm',nclust)).(iband).T(:,:,:);
            T = reshape(T,niter,nshf,size(T,2),size(T,3));
            c = squeeze(T(:,:,1,:)==T(:,:,2,:));
            perm_m(nclust-1) = mean(c,'all');
            perm_975(nclust-1) = prctile(mean(c,[2,3]),97.5);
            perm_025(nclust-1) = prctile(mean(c,[2,3]),2.5);
        end
        subplot(3,5,5*ib-4); hold on;
        plot(1:5,mean(cons,2),'-ok','DisplayName','data','MarkerSize',2,'MarkerFaceColor','k');
        plot(1:5,[1,perm_m],'-k','DisplayName','null');
        fill([1:5,5:-1:1],[1,perm_975,fliplr(perm_025),1],'k','FaceAlpha',0.3,'EdgeAlpha',0,'HandleVisibility','off');
        xlabel('n_{clusters}'); ylabel('Reliability');
        ylim([0.2,1]);
        lgd = legend('boxoff'); xlim([0,6]);
        lgd.Position(1) = 0.2;
        title(sprintf('Cluster by %s',iband))
        set(gca,'TickDir','out');
        % Plot reliability by location
        if strcmp(iband,'HighGamma') && strcmp(ianm,"R"); cl = [0.2,0.5];
        elseif strcmp(ianm,"W"); cl = [0.2,0.8];
        else; cl = [0.2,1];
        end
%         cmap = colormap(gca,viridis(100));
        cmap = colormap(gca,hot(125));
%         cmap = [linspace(0.5, 1, 100)', linspace(0, 1, 100)', linspace(0, 0, 100)'];
        for nclust = 2:5
            subplot(3,5,5*ib-5+nclust); colormap(gca,cmap)
            h = plot_dot_byloc(gca,ianm,sprintf('n = %d',nclust));
            xticks([]); yticks([]);
            for il = 1:numel(h)
                locs = BPF_perm.(ianm).loc_list(il,:);
                x = cons(nclust,il);
                xc = round((x-cl(1))./diff(cl)*100);
                if xc>100; xc = 100; end
                if xc<1; xc=1; end
                h{il}.FaceColor = cmap(xc,:);
%                 text(locs(1),locs(2),sprintf('%d%%',round(x*niter)),'HorizontalAlignment','center','FontSize',5);
            end
%             colorbar; 
            clim([cl(1),cl(1)+diff(cl)/4*5]);
        end
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf,'Renderer','painters');
    print(fullfile(outf,sprintf('Consist_bynclust_%s_hot_bl_CI95.png',ianm)),'-dpng');
    print(fullfile(outf,sprintf('Consist_bynclust_%s_hot_bl_CI95.pdf',ianm)),'-dpdf','-r0','-bestfit');
end
%% functions
function get_burst_rate_splthf(filename,niter)
% This function gets the burst-rate estimation for each condition (4x5),
% by new definition of frequency bands: high/lowGamma & Beta
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(inf,filename),'data_burst');
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/25.ObjClust/Consist/PermBPF';
burst_rate = struct();
trialinfo = data_burst.trialinfo(~data_burst.badtrials(:)&data_burst.trialinfo.errorcode(:)==0,:);
% get mean burst rate by iterating n times for the stratification
for iband = ["HighGamma","Beta"]
    switch iband
        case 'HighGamma'; frng = [60 90];
        case 'Beta'; frng = [15 35];
    end
    burst_sel = cellfun(@(x) x(x.f>=frng(1) & x.f<frng(2),:),trialinfo.bursts, 'uni',0);
    h1 = cell(niter,4,4); h2 = h1;
    for iter = 1:niter
        idx = sort_condition_sampxdist(trialinfo,'no');
        [idx1,idx2] = cellfun(@splithalf,idx,'UniformOutput',false);
        h1(iter,:,:) = cellfun(@(x) rate_trace(burst_sel(x,:),data_burst.time)', idx1,'uni',0);
        h2(iter,:,:) = cellfun(@(x) rate_trace(burst_sel(x,:),data_burst.time)', idx2,'uni',0);
    end
    burst_rate.(iband) = cat(4,h1,h2);
end
save(fullfile(outf,filename),'burst_rate');
end

function [i1,i2] = splithalf(i)
l = length(i);
i = i(randperm(l));
i1 = i(1:ceil(l/2)); i2 = i(floor(l/2):end);
end