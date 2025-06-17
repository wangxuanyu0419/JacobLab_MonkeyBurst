function trls = trialfilter(trialinfo,cndspec)
trls = true(height(trialinfo),1);

if isfield(cndspec,'trialerror')
    trls = trls & trialinfo.trialerror == 'correct';
end

if isfield(cndspec,'saturation')
    trls = trls & cellfun(@(raw_sat) trial_voltoutliers_acceptable(full(raw_sat),...
        cndspec.saturation.time, ...
        cndspec.saturation.time_range, ...
        cndspec.saturation.frac_acceptable_outliers), ...
        trialinfo.raw_sat);
end

if isfield(cndspec,'drug')
    % single logical value from drug assessment is broadcast to ntrl-by-1 logical array
    trls = trls & strcmp(cndspec.drug,trialinfo.Properties.CustomProperties.drug);
end

if isfield(cndspec,'drug_mode')
    if ismember('trialdrugind',trialinfo.Properties.VariableNames)
        trls = trls & trialinfo.trialdrugind==cndspec.drug_mode;
    else
        trls = trls & false;
    end
end

if isfield(cndspec,'sample')
    trls = trls & ismember(trialinfo.sample,cndspec.sample);
end

if isfield(cndspec,'distractor')
    trls = trls & ismember(trialinfo.distractor,cndspec.distractor);
end
