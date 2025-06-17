function acceptable = trial_voltoutliers_acceptable(outliers, trial_time, trial_time_check_range, acceptable_fraction_outliers)
    % Checks if fraction of outliers in a trial is within acceptable range.
    %
    % Input
    % -----
    % outliers: logical
    %   Vector of length(trial_time) that is true when recorded voltage was outside acceptable range.
    % trial_time: double
    %   Vector of length(outliers) that specifies an arbitrary trial time.
    % trial_time_check_range: double
    %   Vector of length 2 that defines a range within trial_time to be checked for outliers.
    % acceptable_fraction_outliers: double
    %   Scalar in the range [0 1] that specifies the acceptable fraction of outliers within trial_time_check_range.
    %
    % Output
    % ------
    % acceptable: logical
    %   True if trial has less or equal the acceptable fraction of outliers within the checked trial range.

    trial_time_check_range = sort(trial_time_check_range);
    if length(trial_time_check_range) ~= 2
        error('Trial time range to be checked must be specified as a 2-element vector.');
    end
    if trial_time_check_range(1) < min(trial_time) || trial_time_check_range(2) > max(trial_time)
        warning('Trial time range to be checked outside trial times.')
    end
    idx_check = trial_time>=trial_time_check_range(1) & trial_time<=trial_time_check_range(2);

    acceptable = (sum(outliers(idx_check))/sum(idx_check)) <= acceptable_fraction_outliers;
