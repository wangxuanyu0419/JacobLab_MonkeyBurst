% Compare OCP across sites from the same session, analyze per session basis
clear
close all

sessf = '/mnt/storage/xuanyu/MONKEY/Non-ion/sat_time';
sessdir = dir(fullfile(sessf,'*.mat'));
sessname = {sessdir.name}; % 78 sessions
nsess = numel(sessname);
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/13.PerfOCP/OCP_sess_inclerror';
mkdir(outf);

delete(gcp('nocreate'))
pools = parpool(32);

parfor isess = 1:nsess
    get_OCP_sess_inclerror(sessname{isess});
end

%% Get summary from each session
inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/13.PerfOCP/OCP_sess_inclerror';
outf = '/mnt/storage/xuanyu/JacobLabMonkey/data/13.PerfOCP';
OCP_summary = struct();
OCP_summary.sessions = sessname;

for isess = 1:numel(sessname)
    load(fullfile(inf,sessname{isess}),'OCP');
    OCP_summary.OCP{isess} = OCP;
    fprintf('>>> Loading data... Completed %.01f %% \n',isess/numel(sessname)*100);
end

save(fullfile(outf,'OCP_summary_inclerror.mat'),'OCP_summary');

%% Compute 