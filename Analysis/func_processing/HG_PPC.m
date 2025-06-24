% spetral-wise PPC with gliding window
% all correct trials, baseline PPC not included (too much computation)

close all
clear

inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Phasemap';
dirf = dir(fullfile(inf,'*.mat'));
files = {dirf.name};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
step = 100;
win = 250;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outf = sprintf('/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/HG_PPC/step%03d_win%03d',step,win);
try mkdir(outf); catch; end

% % test session
% channame = files{2}
% HG_PPC_chan(channame,step,win);
% fprintf('>>> Completed %s \n',channame);
% 
% delete(gcp('nocreate'));
% parpool(16);
% par

prog = 0.0;
fprintf('>>> Completed %3.0f%%\n',prog)

for i = 1:numel(files)
    try
        HG_PPC_chan(files{i},step,win);
%         fprintf('>>> Completed %s \n',files{i});
        prog = i/numel(files)*100; fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
    catch e
        fprintf('!!! WARNING: Problem processing %s \n     %s\n',files{i},e.message);
    end
end

%% Summary
inf = sprintf('/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/HG_PPC/step%03d_win%03d',step,win);
dirf = dir(fullfile(inf,'*.mat'));
files = {dirf.name};
outf = sprintf('/mnt/storage/xuanyu/JacobLabMonkey/data/16.PhaseCoup/HG_PPC/step%03d_win%03d',step,win);
mkdir(outf);

HG_PPC_sum = struct();
HG_PPC_sum.files = files;
HG_PPC_sum.animal = cellfun(@(s) s(1),files,'uni',0);
regs = ["PFC","VIP"];
HG_PPC_sum.region = cellfun(@(s) regs((str2double(s(11:12))>8)+1),files,'uni',0);
load(fullfile(inf,files{1}));
HG_PPC_sum.freq = HG_PPC.freq;
HG_PPC_sum.tds = HG_PPC.tds;

HG_PPC_sum.PPC = nan(numel(files),length(HG_PPC_sum.tds),length(HG_PPC_sum.freq));

prog = 0.0;
fprintf('>>> Completed %3.0f%%\n',prog)
for ich = 1:numel(files)
    load(fullfile(inf,files{ich}));
    HG_PPC_sum.PPC(ich,:,:) = HG_PPC.PPC;
    prog = ich/numel(files)*100; fprintf(1,'\b\b\b\b\b%3.0f%%\n',prog);
end
HG_PPC_sum = ft_struct2single(HG_PPC_sum);
save(fullfile(outf,'HG_PPC_sum'),'HG_PPC_sum');

%% plot, pool animals
dirf = outf;
close all
fig = figure('Position',[100 100 900 400]);
freq = HG_PPC_sum.freq; tds = HG_PPC_sum.tds;

for ireg = ["PFC","VIP"]
    switch ireg
        case 'PFC'; x0 = 0.06; cl = [-0.01 0.02];
        case 'VIP'; x0 = 0.6; cl = [-0.01 0.03];
    end
    reg_list = cellfun(@(s) strcmp(s,ireg),HG_PPC_sum.region);
    ax = axes(fig,'Position',[x0,0.12,0.37,0.76]); hold on;
    title(ireg,'FontSize',15);
    data = HG_PPC_sum.PPC(reg_list,:,:);
    avg = squeeze(nanmean(data));
    hold on;
    set(gca,'YDir','normal','box','off','TickDir','out');
    imagesc(tds,freq,avg');
    arrayfun(@(x) plot([x x],[2,90],'--w'),[0 0.5 1.5 2 3]);
    xlim([-0.5,3.1]); xlabel('Time to sample onset [s]');
    ylim([2,90]);
    caxis(cl);
    ylabel('Frequency [Hz]')
    cb = colorbar('Location','eastoutside');
    cb.Label.String = 'PPC';
end
set(gcf, 'InvertHardCopy', 'off'); % setting 'grid color reset' off
set(gcf, 'Color', [1 1 1]); %setting figure window background color back to white
print(fullfile(dirf,'HG_PPC_sum'),'-dpng');

%%
function HG_PPC_chan(channame,step,win)
% number of bursts balanced
phsf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/Phasemap';
load(fullfile(phsf,channame),'data_phase');
brstf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(brstf,channame),'data_burst');
outrf = '/mnt/storage/xuanyu/MONKEY/Non-ion/16.PhaseCoup/HG_PPC';
outf = sprintf('%s/step%03d_win%03d',outrf,step,win);

ntrl = height(data_phase.trialinfo);
Gammalim = [60,90];
tlim = [-0.5,3.5];

frng = 1:90;
HG_PPC = struct();
HG_PPC.label = data_burst.label;
HG_PPC.freq = data_burst.freq(frng);
HG_PPC.time = data_burst.time;
tsel = data_burst.time>=tlim(1) & data_burst.time<=tlim(2);
HG_PPC.step = step;
HG_PPC.win = win;
HG_PPC.tds = downsample(HG_PPC.time(tsel),HG_PPC.step);
HG_PPC.badtrials = data_burst.badtrials;
HG_PPC.trialinfo = data_phase.trialinfo;

TRL = HG_PPC.trialinfo.errorcode==0 & ~HG_PPC.badtrials';

HG_PPC.CNT = nan(length(HG_PPC.tds),1);
HG_PPC.PPC = nan(length(HG_PPC.tds),length(HG_PPC.freq));
HG_PPC.PPC_bl = nan(length(HG_PPC.tds),length(HG_PPC.freq));
PPC_bl = nan(ntrl,length(HG_PPC.tds),length(HG_PPC.freq));

for itrl = 1:ntrl
    b = data_burst.trialinfo.bursts{itrl};
    b_HG = b(b.f>=Gammalim(1)&b.f<=Gammalim(2)&b.t>=tlim(1)&b.t<=tlim(2),:);
    [~,tpk] = arrayfun(@(t) min(abs(HG_PPC.time-t)), b_HG.t); % peak time
    phtrl = squeeze(data_phase.phase(itrl,frng,:));
    Tpks{itrl} = HG_PPC.time(tpk)';
    Phases{itrl} = phtrl(:,tpk)';
%     Phases_bl{itrl} = phtrl';
end

TPK = vertcat(Tpks{TRL});
PHS = vertcat(Phases{TRL});
for t = 1:length(HG_PPC.tds)
    twin = HG_PPC.tds(t)+HG_PPC.win/2e3.*[-1,1];
%     tsel = data_burst.time>=twin(1) & data_burst.time<=twin(2);
%     PHS_bl = cellfun(@(p) p(tsel,:),Phases_bl,'uni',0);
    bsel = find(TPK>=twin(1)&TPK<=twin(2));
    HG_PPC.CNT(t) = length(bsel);
    HG_PPC.PPC(t,:) = calPPC(PHS(bsel,:));
%     for itrl = 1:ntrl
%         PPC_bl(itrl,t,:) = calPPC(PHS_bl{itrl});
%     end
end
% HG_PPC.PPC_bl = squeeze(mean(PPC_bl(TRL,:,:)));

HG_PPC = ft_struct2single(HG_PPC);
save(fullfile(outf,channame),'HG_PPC');
end