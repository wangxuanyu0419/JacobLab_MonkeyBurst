clear; close all; clc;
sumf = '/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/Burst_phase_examples';
outfigf = '/mnt/storage/xuanyu/JacobLabMonkey/data/Pub_figs';
load(fullfile(sumf,'PHS_BT_3Hz'),'PHS_BT_3Hz');
load(fullfile(sumf,'PHS_HG_29Hz'),'PHS_HG_29Hz');
close all; fig = figure('Position',[0 0 1000 500]);
binedgs = linspace(0,2*pi,24);
for ireg = ["PFC","VIP"]
    clf(fig,'reset');
    regsel = cellfun(@(s) strcmp(s,ireg),PHS_BT_3Hz.region);
    for iband = ["HG","BT"]
        [~,ib] = ismember(iband,["HG","BT"]);
        switch iband
            case 'BT'; PHS = PHS_BT_3Hz;
            case 'HG'; PHS = PHS_HG_29Hz;
        end
        for icond = ["s1","s2","s3","s4"]
            [~,ic] = ismember(icond,["s1","s2","s3","s4"]);
            subplot(2,4,(ib-1)*4+ic);
            d = PHS.MPH_num.(icond)(regsel & PHS.sig_num.(icond)');
            d0 = angle(mean(exp(1i*d),'omitnan'));
            polarhistogram(d,'BinEdges',binedgs); hold(gca,'on');
            rl = rlim();
            l = plot(gca,[0,d0],rl,'r','LineWidth',2);
            rlim(rl);
            %text(pi/6,rl(2)/2,'# Chan','Rotation',30,'FontSize',8,'HorizontalAlignment','center');
            set(gca,'ThetaAxisUnits','radians');
            thetalim([-pi,pi]);
            thetaticks([-2/3*pi,-pi/3,0,pi/3,pi*2/3,pi]);
        end
    end
    set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
    set(gcf,'Renderer','painters');
    print(fullfile(outfigf,sprintf('Burst_mean_phase_numbers_new_%s',ireg)),'-dpdf','-r0','-bestfit');
    print(fullfile(outfigf,sprintf('Burst_mean_phase_numbers_new_%s',ireg)),'-dpng');
end
