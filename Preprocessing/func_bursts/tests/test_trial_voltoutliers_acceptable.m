function tests = test_trial_voltoutliers_acceptable()
    tests = functiontests(localfunctions);
end

function test_nooutliers(test_case)
    % given
    trial_time = -1.5:0.001:4;
    trial_time_check_range = [-1 3.6];
    outliers = false(5501,1);
    acceptable_fraction_outliers = 0.001;
    expected = true;
    % when
    output = trial_voltoutliers_acceptable(outliers, trial_time, trial_time_check_range, acceptable_fraction_outliers);
    % then 
    verifyEqual(test_case,output,expected);
end

function test_alloutliers(test_case)
    % given
    trial_time = -1.5:0.001:4;
    trial_time_check_range = [-1 3.6];
    outliers = true(5501,1);
    acceptable_fraction_outliers = 0.001;
    expected = false;
    % when
    output = trial_voltoutliers_acceptable(outliers, trial_time, trial_time_check_range, acceptable_fraction_outliers);
    % then 
    verifyEqual(test_case,output,expected);
end

function test_outliers_acceptable(test_case)
    % given
    trial_time = -1.5:0.001:4;
    trial_time_check_range = [-1 3.6];
    outliers = false(5501,1);
    outliers(ismember(trial_time,-1.5:1.2:4)) = true;
    acceptable_fraction_outliers = 0.001;
    expected = true;
    % when
    output = trial_voltoutliers_acceptable(outliers, trial_time, trial_time_check_range, acceptable_fraction_outliers);
    % then 
    verifyEqual(test_case,output,expected);
end

function test_outliers_notacceptable(test_case)
    % given
    trial_time = -1.5:0.001:4;
    trial_time_check_range = [-1 3.6];
    outliers = false(5501,1);
    outliers(ismember(trial_time,-1:1:4)) = true;
    acceptable_fraction_outliers = 0.001;
    expected = false;
    % when
    output = trial_voltoutliers_acceptable(outliers, trial_time, trial_time_check_range, acceptable_fraction_outliers);
    % then 
    verifyEqual(test_case,output,expected);
end
