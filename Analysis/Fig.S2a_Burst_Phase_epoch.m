% compute meanphase by task epoch
clear; close all;
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Phasemap';
dif = dir(fullfile(inf,'*.mat')); files = {dif.name};
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Burst_phase_epochs_newtgt'; mkdir(outf);
delete(gcp('nocreate')); parpool(32);
for iband = ["Gamma","Beta_PFC","Beta_VIP"]
	switch iband
        case 'Gamma'; infile = 'PHS_HG'; frng = [60,90]; ftgt = 29; outfile = 'PHS_HG_29Hz';
        case 'Beta'; infile = 'PHS_BT'; frng = [15,35]; ftgt = 3; outfile = 'PHS_BT_3Hz';
	end
	mkdir(fullfile(outf,infile));
	load(fullfile('/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/Burst_peak_phase',infile));
	eval(sprintf('PHS = rmfield(%s,"MPH");',infile));
	PHS.MPH = nan(numel(PHS.channel),5); % add sorting by epoch
	PHS.sig = false(numel(PHS.channel),5);
	parfor i = 1:numel(files)
		Phase_chan_epochs(files{i},frng,ftgt,fullfile(outf,infile));
		fprintf('>>> Completed %d/%d, %s\n',i,numel(files),files{i});
	end
	load(fullfile(outf,infile,files{1}),'MPH'); % load example channel
	PHS.epochs = MPH.epochs;
	PHS.epoch_names = MPH.epoch_names;
	for i = 1:numel(files)
		load(fullfile(outf,infile,files{i}),'MPH');
		for iep = 1:5
			PHS.MPH(i,iep) = angle(MPH.(MPH.epoch_names{iep}).MVC_n);
			PHS.sig(i,iep) = MPH.(MPH.epoch_names{iep}).sig;
		end
		fprintf('Loading data, completed %d/%d\n',i,numel(files));
	end
	save(fullfile(outf,outfile),'PHS');
end

%% Plot results
outfigf = '/mnt/storage/xuanyu/xuanyu_monkeybursts/data/Pub_figs';
close all;
fig = figure('Position',[0 0 1000 500]);
binedgs = linspace(0,2*pi,24);
for ireg = ["PFC","VIP"]
	clf(fig,'reset');
	regsel = cellfun(@(s) strcmp(s,ireg),PHS_HG.region);
	for iband = ["HighGamma","Beta"]
		switch iband
    		case 'HighGamma'; infile = 'PHS_HG_29Hz'; ib = 1;
            case 'Beta'; if ireg=="PFC"; infile = 'PHS_BT_3Hz'; else; infile = 'PHS_BT_13Hz'; end; ib = 2;
		end
		load(fullfile(outf,infile),'PHS');
		for iep = 1:5
			subplot(2,5,ib*5+iep-5);
			d = PHS.MPH(regsel,iep);
			d = d(PHS.sig(regsel,iep));
			d0 = angle(nanmean(exp(1i*d)));
			polarhistogram(d,'BinEdges',binedgs); hold(gca,'on');
	                rl = rlim();
			l = plot(gca,[0,d0],rl,'r','LineWidth',2);
			rlim(rl);
			set(gca,'ThetaAxisUnits','radians');
			thetalim([-pi,pi]);
			thetaticks([-2/3*pi,-pi/3,0,pi/3,pi*2/3,pi]);
		end
	end
	set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
	set(gcf,'Renderer','painters');
	print(fullfile(outfigf,sprintf('Burst_mean_phase_epochs_new_%s',ireg)),'-dpng');
	print(fullfile(outfigf,sprintf('Burst_mean_phase_epochs_new_%s',ireg)),'-dpdf','-r0','-bestfit');
end

%% functions
function Phase_chan_epochs(chan,frng,ftgt,outf)
phsf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Phasemap';
load(fullfile(phsf,chan),'data_phase');
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(brstf,chan),'data_burst');
ntrl = height(data_phase.trialinfo);
freq = data_burst.freq;
MPH = struct();
MPH.label = data_burst.label;
MPH.freq = freq;
MPH.frng = frng;
MPH.ftgt = round(freq)==ftgt;
MPH.time = data_burst.time;
MPH.badtrials = data_burst.badtrials;
MPH.epoch_names = {'BL','Samp','Mem1','Dist','Mem2'}; % five epochs named
MPH.epochs = {[-0.5,0],[0.1,0.6],[0.6,1.6],[1.6,2.1],[2.1,3.1]};
MPH.trialinfo = data_phase.trialinfo;
MPH.alpha = 0.001;
trlsel = MPH.trialinfo.errorcode==0 & ~MPH.badtrials' & MPH.trialinfo.distractor~=0; % choose correct trials with distractor
% get all burst peak phases during task epochs
for iep = 1:numel(MPH.epochs)
	tlim = MPH.epochs{iep}; epoch = MPH.epoch_names{iep};
	% get mean vector and baseline
	for itrl = 1:ntrl
		b = data_burst.trialinfo.bursts{itrl};
		b_HG = b(b.f>=frng(1)&b.f<=frng(2)&b.t>=tlim(1)&b.t<=tlim(2),:);
		[~,tpk] = arrayfun(@(t) min(abs(MPH.time-t)), b_HG.t); % peak time
		phtrl = squeeze(data_phase.phase(itrl,MPH.ftgt,:));
		Tpks{itrl} = MPH.time(tpk)';
		Phases_bl(itrl,:) = phtrl;
		Phases{itrl} = phtrl(tpk);
	end
	MPH.(epoch).Tpks = vertcat(Tpks{trlsel});
	MPH.(epoch).Phases = vertcat(Phases{trlsel});
	MPH.(epoch).MVC = calMVC(MPH.(epoch).Phases);
	[MPH.(epoch).MVC_bl,MPH.(epoch).MVC_perm] = calMVC_perm(Phases_bl(:),length(MPH.(epoch).Phases));
	MPH.(epoch).MVC_n = MPH.(epoch).MVC - MPH.(epoch).MVC_bl;
	MPH.(epoch).THR = prctile(abs(MPH.(epoch).MVC_perm),100*(1-MPH.alpha),1);
	MPH.(epoch).sig = abs(MPH.(epoch).MVC_n)>MPH.(epoch).THR;
end
save(fullfile(outf,chan),'MPH');
end
