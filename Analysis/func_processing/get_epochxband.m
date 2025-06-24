function get_epochxband(filename,epochs,bands)
% This function calculates burst modulated firing rate epoch x band x in/out
%
% ---
% Input:
%   - filename: string, name of the data_comb file of multiunit spikes
%   - epochs: n x 1 cell, temporal boundaries of each epoch
%   - bands: n x 1 cell, frequency bands
%
% ---
% Output:
%   - fr_mat, matrix of FR, saved in .../Non-ion/7.BTA_multi/1.EpochxBand
%   folder, on linear scale [Hz]

inf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi';
outf = '/mnt/storage/xuanyu/MONKEY/Non-ion/7.BTA_multi/1.EpochxBand_newband';

load(fullfile(inf,filename),'data_comb');
trialinfo = data_comb.trialinfo(~data_comb.badtrials,:);
ntrl = height(trialinfo);
fr_mat = nan(numel(epochs),numel(bands),2,ntrl); % nepoch x nband x in/out
fs = 1000;
t = -1:1/fs:4;
for itrl = 1:ntrl
    spks = trialinfo.multispike{itrl};
    
    for iband = 1:numel(bands)
        band = bands{iband};
        brsts = trialinfo.bursts{itrl};
        brsts = brsts(brsts.f>band(1) & brsts.f<band(2),:);
        fwhm = gauss_fwfracm(brsts.t_sd,1/2);
        is_in = arrayfun(@(spk) any(arrayfun(@(mu,sd) spk>(mu-sd)&spk<(mu+sd),brsts.t,fwhm/2)),spks);
        spk_in = spks(is_in); spk_out = spks(~is_in);
        brst_idc = arrayfun(@(ti) any(arrayfun(@(mu,sd) ti>(mu-sd)&ti<(mu+sd),brsts.t,fwhm/2)),t);
        
        for iep = 1:numel(epochs)
            epoch = epochs{iep};
            fr_mat(iep,iband,1,itrl) = sum(spk_in>epoch(1) & spk_in<epoch(2)) / sum(brst_idc & t>epoch(1) & t<=epoch(2)) * 1000;
            fr_mat(iep,iband,2,itrl) = sum(spk_out>epoch(1) & spk_out<epoch(2)) / sum(~brst_idc & t>epoch(1) & t<=epoch(2)) * 1000;
        end
    end
end

fr_mat = squeeze(nanmean(fr_mat,4));

save(fullfile(outf,filename),'fr_mat');
fprintf('>>> Completed %s\n',filename);
end