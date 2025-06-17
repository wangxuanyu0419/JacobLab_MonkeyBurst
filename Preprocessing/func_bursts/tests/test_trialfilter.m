function tests = test_trialfilter()
    tests = functiontests(localfunctions);
end

function test_trialerror_allcorrect(testCase)
    % Given
    trialerror = categorical(zeros(100,1),0,'correct');
    trialinfo = table(trialerror,'VariableNames',{'trialerror'});
    cndspec.trialerror = 'correct';
    expected = true(100,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected)
end

function test_trialerror_allwrong(testCase)
    % Given
    trialerror = categorical(ones(100,1)*6,6,'wrong');
    trialinfo = table(trialerror,'VariableNames',{'trialerror'});
    cndspec.trialerror = 'correct';
    expected = false(100,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected)
end

function test_trialerror_halfwrong(testCase)
    % Given
    trialerror = categorical(zeros(100,1),[0 6],{'correct' 'wrong'});
    trialerror(1:2:100) = 'wrong';
    trialinfo = table(trialerror,'VariableNames',{'trialerror'});
    cndspec.trialerror = 'correct';
    expected = false(100,1);
    expected(2:2:100) = true;
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected)
end

function test_saturation_allvalid(testCase)
    % Given
    cndspec.saturation.time_range = [-1 3.6];
    cndspec.saturation.time = -1.5:0.001:4;
    cndspec.saturation.frac_acceptable_outliers = 0.001;
    ntrl = 100;
    raw_sat = repmat({sparse(false(numel(cndspec.saturation.time),1))}, ntrl, 1);
    trialinfo = table(raw_sat,'VariableNames',{'raw_sat'});
    expected = true(100,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected)
end

function test_saturation_nonevalid(testCase)
    % Given
    cndspec.saturation.time_range = [-1 3.6];
    cndspec.saturation.time = -1.5:0.001:4;
    cndspec.saturation.frac_acceptable_outliers = 0.001;
    ntrl = 100;
    raw_sat = repmat({true(numel(cndspec.saturation.time),1)}, ntrl, 1);
    trialinfo = table(raw_sat,'VariableNames',{'raw_sat'});
    expected = false(100,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected)
end

function test_saturation_halfvalid(testCase)
    % Given
    cndspec.saturation.time_range = [-1 3.6];
    cndspec.saturation.time = -1.5:0.001:4;
    cndspec.saturation.frac_acceptable_outliers = 0.001;
    ntrl = 100;
    raw_sat = repmat({sparse(false(numel(cndspec.saturation.time),1))}, ntrl, 1);
    idx_check = find(cndspec.saturation.time >= cndspec.saturation.time_range(1) & ...
        cndspec.saturation.time <= cndspec.saturation.time_range(2));
    % add acceptable number of outliers
    for i = 1:ntrl/2
        raw_sat{i}(randsample(idx_check,floor(numel(idx_check)*cndspec.saturation.frac_acceptable_outliers))) = true;
    end
    % add unacceptable number of outliers
    for i = ntrl/2+1:ntrl
        raw_sat{i}(randsample(idx_check,ceil(numel(idx_check)*cndspec.saturation.frac_acceptable_outliers))) = true;
    end
    trialinfo = table(raw_sat,'VariableNames',{'raw_sat'});
    expected = vertcat(true(ntrl/2,1),false(ntrl/2,1));
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected)
end

function test_correctdrug(testCase)
    % Given
    cndspec.drug = 'SCH23390';
    ntrl = 100;
    trialinfo = table('Size',[ntrl 1],'VariableTypes',{'logical'});
    trialinfo = addprop(trialinfo,{'drug'},{'table'});
    trialinfo.Properties.CustomProperties.drug = 'SCH23390';
    expected = true(ntrl,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end

function test_wrongdrug(testCase)
    % Given
    cndspec.drug = 'wrongDrug';
    ntrl = 100;
    trialinfo = table('Size',[ntrl 1],'VariableTypes',{'logical'});
    trialinfo = addprop(trialinfo,{'drug'},{'table'});
    trialinfo.Properties.CustomProperties.drug = 'SCH23390';
    expected = false(ntrl,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end


function test_drugmode_30match60nonmatch(testCase)
    % Given
    cndspec.drugmode = 'ejection';
    ntrl = 90;
    shuffled_idx = randperm(ntrl);
    drugmodes = zeros(ntrl,1);
    drugmodes(shuffled_idx(1:30)) = 0;
    drugmodes(shuffled_idx(31:60)) = 1;
    drugmodes(shuffled_idx(61:90)) = 2;
    drugmodes = categorical(drugmodes,[0 1 2],{'ejection','retention','invalid'});
    trialinfo = table(drugmodes,'VariableNames',{'trialdrugind'});

    expected = false(ntrl,1);
    expected(shuffled_idx(1:30)) = true;
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end

function test_drugmode_missing(testCase)
    % Given
    cndspec.drugmode = 'ejection';
    ntrl = 100;
    trialinfo = table('Size',[ntrl 1],'VariableTypes',{'logical'});
    expected = false(ntrl,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end

function test_samplematchhalf(testCase)
    % Given
    cndspec.sample = 1;
    ntrl = 100;
    shuffled_idx = randperm(ntrl);
    sample = ones(ntrl,1);
    sample(shuffled_idx(1:ntrl/2)) = 1;
    sample(shuffled_idx(ntrl/2+1:end)) = 2;
    trialinfo = table(sample,'VariableNames',{'sample'});
    expected = false(ntrl,1);
    expected(shuffled_idx(1:ntrl/2)) = true;
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end

function test_sample_allmatch_vector(testCase)
    % Given
    cndspec.sample = [1 2 4];
    ntrl = 100;
    sample = randi(3,ntrl,1);
    sample(sample==3) = 4;
    trialinfo = table(sample,'VariableNames',{'sample'});
    expected = true(ntrl,1);
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end

function test_distrmatchhalf(testCase)
    % Given
    cndspec.distractor = 1;
    ntrl = 100;
    shuffled_idx = randperm(ntrl);
    distractor = ones(ntrl,1);
    distractor(shuffled_idx(1:ntrl/2)) = 1;
    distractor(shuffled_idx(ntrl/2+1:end)) = 2;
    trialinfo = table(distractor,'VariableNames',{'distractor'});
    expected = false(ntrl,1);
    expected(shuffled_idx(1:ntrl/2)) = true;
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end

function test_distractor_vector_matchnonzero(testCase)
    % Given
    cndspec.distractor = [1 2 4];
    ntrl = 100;
    distractor = randi(4,ntrl,1);
    distractor(distractor==3) = 0;
    trialinfo = table(distractor,'VariableNames',{'distractor'});
    expected = true(ntrl,1);
    expected(distractor==0) = false;
    % When
    output = trialfilter(trialinfo,cndspec);
    % Then
    verifyEqual(testCase,output,expected);
end
