function get_OCP_sess_inclerror(session)
% This function computes OCP of all channels for each session

chanf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
chandir = dir(fullfile(chanf,[session(1:7),'-*']));
channame = {chandir.name};
nchan_sess = numel(channame);
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/13.PerfOCP/OCP_sess_inclerror';

% Initialize output
OCP = struct();
OCP.channame = channame;
OCP.chan_reg = cell(size(channame));

for ichan = 1:nchan_sess
    if str2double(channame{ichan}(11:12))<=8; OCP.chan_reg{ichan} = 'PFC';
    else; OCP.chan_reg{ichan} = 'VIP'; end
    
    load(fullfile(chanf,channame{ichan}),'data_burst');
    trl_sel = data_burst.trialinfo; % contain badtrials
    time = data_burst.time;
    
    if ichan == 1; OCP.trialinfo = trl_sel(:,1:5); end
    
    for iband = ["Beta","LowGamma","HighGamma"]
        OCP.(iband)(:,ichan) = get_occup_dist(trl_sel,time,iband);
        OCP.(iband)(data_burst.badtrials==1,ichan) = nan(sum(data_burst.badtrials==1),1); % substitute badtrials with missing 'nan'
    end
end

save(fullfile(outf,session),'OCP');
fprintf('>>> Completed %s \n',session);
