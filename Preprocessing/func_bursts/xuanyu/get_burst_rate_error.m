function get_burst_rate_error(filename)
% This function gets the burst-rate estimation for error-trials,
% by new definition of frequency bands: high/lowGamma & Beta

inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/3.Bursts_inclerror/no_sat_1cyc';
load(fullfile(inf,filename),'data_burst');
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/4.BurstStat/Rate_NewBand_Error';

burst_rate = struct();
for icorr = ["corr","wrng","miss"]
    switch icorr
        case 'corr'
            trialinfo = data_burst.trialinfo(~data_burst.badtrials(:) & data_burst.trialinfo.errorcode(:)==0,:);
        case 'wrng'
            trialinfo = data_burst.trialinfo(~data_burst.badtrials(:) & data_burst.trialinfo.errorcode(:)==6,:);
        case 'miss'
            trialinfo = data_burst.trialinfo(~data_burst.badtrials(:) & data_burst.trialinfo.errorcode(:)==1,:);
    end
    % get mean burst rate by iterating 25 times for the stratification
    for iBand = ["HighGamma","LowGamma","Beta"]
        switch iBand
            case 'HighGamma'; frng = [60 90];
            case 'LowGamma'; frng = [35 60];
            case 'Beta'; frng = [15 35];
        end
        burst_sel = cellfun(@(x) x(x.f>=frng(1) & x.f<frng(2),:),trialinfo.bursts, 'uni',0);
        burst_rate.(icorr).(iBand) = rate_trace(burst_sel,data_burst.time)';
    end
end

save(fullfile(outf,filename),'burst_rate');
fprintf('>>> Completed %s\n',filename);
end