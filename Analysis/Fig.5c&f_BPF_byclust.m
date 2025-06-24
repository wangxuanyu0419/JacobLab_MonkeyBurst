% Plot mean burst-probability function with comparison across clusters
clear; close all; clc;
load('/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/T','T');
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/4.BurstStat/Rate_NewBand';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/4.BurstStat/Rate_allcond_NewBand/data_sum','data_sum');
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_VIP2PFC_byepoch_byloc';
load('/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/SFC/rmERP_VIP2PFC_byepoch_byloc/SFC_sum','SFC_sum');
PFCchan = SFC_sum.PFCchan;
Bands = ["Beta","HighGamma"]; time = -1:1/1000:4;
prog = 0.0;
fprintf('>>> Loading Data, completed %3.0f%%\n',prog)
for iband = Bands
    PFCchan.(iband) = cell(height(PFCchan),1);
end
for ifile = 1:height(PFCchan)
    load(fullfile(inf,PFCchan.channels{ifile}),'burst_rate');
    for iband = Bands
        mat = nan(4,5,length(time));
        for isamp = 1:4
            for idist = 1:4
                mat(isamp,idist,:) = burst_rate.(iband){isamp,idist+1};
            end
        end
        PFCchan.(iband){ifile} = squeeze(mean(mat,[1,2],"omitnan"));
    end
    prog = ifile/height(PFCchan)*100;
    fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
PFCchan = renamevars(PFCchan,'HighGamma','Gamma');
%% calculate and plot together
close all; fig = figure('Position',[0 0 300 400]);
cclust = 'gcmy'; % cluster color (red for memory, cyan for beta site, m for gamma site)
grey = ones(1,3).*0.5;
gaus_win = 150;
xl = [-0.5,3.2];
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/BPF_byclust'; mkdir(outfigf);
for ianm = ["R","W"]
    clf(fig,'reset');
    for iband = ["Beta","Gamma"]
        [~,ib] = ismember(iband,["Gamma","Beta"]);
        switch iband
            case 'Beta'; yl = [0,0.5];
            case 'Gamma'; yl = [0.1,0.4];
        end
        anmsel = find(PFCchan.animal==(char(ianm)));
        lbl = PFCchan.T(anmsel);
        subplot(2,1,ib);
        hold on;
        fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor',grey,'EdgeAlpha',0.1,'HandleVisibility','off');
        n = T.(ianm).nclust;
        for i = 1:n
            d = cat(2,PFCchan.(iband){anmsel(lbl==i)})'; % Ch x T
            m = mean(d,'omitnan'); % S x Ch
            e = ste(d);
            md = smoothdata(m,'gaussian',gaus_win);
            ed = smoothdata(e,'gaussian',gaus_win);
%             fill([time,fliplr(time)],[md+ed,fliplr(md-ed)],cclust(i),'FaceAlpha',0.3,'EdgeColor','none');
            plot(time,md,'Color',cclust(i),'LineWidth',1);
            ylim(yl); xlim(xl); title(iband);
            a = gca;
            a.YAxis.TickDirection = 'out'; a.XAxis.TickDirection = 'out';
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
%     print(fullfile(outfigf,sprintf('BPF_by%dclust_%s',n,ianm)),'-dpng');
    print(fullfile(outfigf,sprintf('BPF_by%dclust_%s',n,ianm)),'-dpdf','-r0','-bestfit');
end
%% smooth and plot separatedly
cb = 'br';
grey = ones(1,3).*0.5;
gaus_win = 150;
xl = [-0.5,3.2]; yl = [0.05,0.4];
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/25.ObjClust/PCA_BR_avgcovmat/stat_avgcovmat/BPF_byclust'; mkdir(outfigf);
for ianm = ["R","W"]
    n = T.(ianm).nclust;
    anmsel = find(PFCchan.animal==(char(ianm)));
    lbl = PFCchan.T(anmsel);
    switch ianm
        case 'R'; close all; fig = figure('Position',[0 0 200 600]);
        case 'W'; close all; fig = figure('Position',[0 0 200 800]);
    end
    for i = 1:n
        subplot(n,1,i);
        hold on;
        fill([0 0.5 0.5 0],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor','none','HandleVisibility','off');
        fill([1.5 2 2 1.5],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor','none','HandleVisibility','off');
        fill([3 3.5 3.5 3],yl([1 1 2 2]),grey,'FaceAlpha',0.3,'EdgeColor','none','HandleVisibility','off');
        for iband = ["Gamma","Beta"]
            [~,ib] = ismember(iband,["Gamma","Beta"]);
            d = cat(2,PFCchan.(iband){anmsel(lbl==i)})'; % Ch x T
            m = mean(d,'omitnan'); % S x Ch
            e = ste(d);
            md = smoothdata(m,'gaussian',gaus_win);
            ed = smoothdata(e,'gaussian',gaus_win);
%             fill([time,fliplr(time)],[md+ed,fliplr(md-ed)],cclust(i),'FaceAlpha',0.3,'EdgeColor','none');
            plot(time,md,'Color',cb(ib),'LineWidth',1);
            ylim(yl); xlim(xl); %title(iband);
            a = gca;
            a.YAxis.TickDirection = 'out'; a.XAxis.TickDirection = 'out';
        end
    end
    set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    print(fullfile(outfigf,sprintf('BPF_by%dclust_%s',n,ianm)),'-dpng');
    print(fullfile(outfigf,sprintf('BPF_by%dclust_%s',n,ianm)),'-dpdf','-r0','-bestfit');
end
