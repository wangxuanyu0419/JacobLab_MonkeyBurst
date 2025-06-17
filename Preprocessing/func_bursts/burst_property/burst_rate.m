function br = burst_rate(bursts,f,t,min_cyc)
% Find bursts at specific frequency range.
%
% INPUT bursts  cell array of length 'trl', containing tables with burst information
%               for each trial
%       f       double vector of length 2. Frequency range for which burst rate is computed.
%       t       double vector containing a complete trial's time in seconds 
%       min_cyc minimum cycle length per burst
%
% OUTPUT    br  burst rate across trials
%               br.nonbin   burst rate of non-binarised bursts (bursts of different 
%                           frequencies could overlap temporally)
%               br.bin      burst rate of binarised bursts (only information about 
%                           occurrence of any burst)

f = sort(f);

nburst = zeros(numel(bursts),numel(t));  
for itrl = 1:numel(bursts)
    if isempty(bursts{itrl})
        % small hack to not stumble during empty trials
        continue
    end
    this_trl = bursts{itrl};
    boi = this_trl.muf>=f(1) & ...
            this_trl.muf<=f(2) & ...
            this_trl.fwhm_cycles>=min_cyc;
    nburst(itrl,:) = ...
        sum(table2array(rowfun(@(mut,st) t>=mut-2.3548*st & t<=mut+2.3548*st, this_trl(boi,{'mut','st_rot'}))),1);
end
br.nonbin = mean(nburst,1);
br.bin = mean(nburst>0,1);
