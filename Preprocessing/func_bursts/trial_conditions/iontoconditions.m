% condition definitions for iontophoresis dataset
cnds = struct;
%% all drugs
cnds(1).name = 'D1+-all_S124_D0124';
cnds(1).relfolder = 'both';

cnds(2).name = 'D1+-all_S1_D0124';
cnds(2).relfolder = fullfile('both','smpl');
cnds(2).trialfilter.sample = 1;

cnds(3).name = 'D1+-all_S2_D0124';
cnds(3).relfolder = fullfile('both','smpl');
cnds(3).trialfilter.sample = 2;

cnds(4).name = 'D1+-all_S4_D0124';
cnds(4).relfolder = fullfile('both','smpl');
cnds(4).trialfilter.sample = 4;

cnds(5).name = 'D1+-all_S124_D124';
cnds(5).relfolder = fullfile('both','dstr');
cnds(5).trialfilter.distractor = [1 2 4];

cnds(6).name = 'D1+-all_S124_D0';
cnds(6).relfolder = fullfile('both','dstr');
cnds(6).trialfilter.distractor = 0;

cnds(7).name = 'D1+-all_S124_D1';
cnds(7).relfolder = fullfile('both','dstr');
cnds(7).trialfilter.distractor = 1;

cnds(8).name = 'D1+-all_S124_D2';
cnds(8).relfolder = fullfile('both','dstr');
cnds(8).trialfilter.distractor = 2;

cnds(9).name = 'D1+-all_S124_D4';
cnds(9).relfolder = fullfile('both','dstr');
cnds(9).trialfilter.distractor = 4;

% SKF38393 (D1 agonist)
    % ejection
cnds(10).name = 'D1+ej_S124_D0124';
cnds(10).relfolder = fullfile('SKF38393','ejection');
cnds(10).trialfilter.drug = 'SKF38393';
cnds(10).trialfilter.drug_mode = 'ejection';

cnds(11).name = 'D1+ej_S1_D0124';
cnds(11).relfolder = fullfile('SKF38393','ejection','smpl');
cnds(11).trialfilter.drug = 'SKF38393';
cnds(11).trialfilter.drug_mode = 'ejection';
cnds(11).trialfilter.sample = 1;

cnds(12).name = 'D1+ej_S2_D0124';
cnds(12).relfolder = fullfile('SKF38393','ejection','smpl');
cnds(12).trialfilter.drug = 'SKF38393';
cnds(12).trialfilter.drug_mode = 'ejection';
cnds(12).trialfilter.sample = 2;

cnds(13).name = 'D1+ej_S4_D0124';
cnds(13).relfolder = fullfile('SKF38393','ejection','smpl');
cnds(13).trialfilter.drug = 'SKF38393';
cnds(13).trialfilter.drug_mode = 'ejection';
cnds(13).trialfilter.sample = 4;

cnds(14).name = 'D1+ej_S124_D124';
cnds(14).relfolder = fullfile('SKF38393','ejection','dstr');
cnds(14).trialfilter.drug = 'SKF38393';
cnds(14).trialfilter.drug_mode = 'ejection';
cnds(14).trialfilter.distractor = [1 2 4];

cnds(15).name = 'D1+ej_S124_D0';
cnds(15).relfolder = fullfile('SKF38393','ejection','dstr');
cnds(15).trialfilter.drug = 'SKF38393';
cnds(15).trialfilter.drug_mode = 'ejection';
cnds(15).trialfilter.distractor = 0;

cnds(16).name = 'D1+ej_S124_D1';
cnds(16).relfolder = fullfile('SKF38393','ejection','dstr');
cnds(16).trialfilter.drug = 'SKF38393';
cnds(16).trialfilter.drug_mode = 'ejection';
cnds(16).trialfilter.distractor = 1;

cnds(17).name = 'D1+ej_S124_D2';
cnds(17).relfolder = fullfile('SKF38393','ejection','dstr');
cnds(17).trialfilter.drug = 'SKF38393';
cnds(17).trialfilter.drug_mode = 'ejection';
cnds(17).trialfilter.distractor = 2;

cnds(18).name = 'D1+ej_S124_D4';
cnds(18).relfolder = fullfile('SKF38393','ejection','dstr');
cnds(18).trialfilter.drug = 'SKF38393';
cnds(18).trialfilter.drug_mode = 'ejection';
cnds(18).trialfilter.distractor = 4;
    % retention
cnds(19).name = 'D1+ret_S124_D0124';
cnds(19).relfolder = fullfile('SKF38393','retention');
cnds(19).trialfilter.drug = 'SKF38393';
cnds(19).trialfilter.drug_mode = 'retention';

cnds(20).name = 'D1+ret_S1_D0124';
cnds(20).relfolder = fullfile('SKF38393','retention','smpl');
cnds(20).trialfilter.drug = 'SKF38393';
cnds(20).trialfilter.drug_mode = 'retention';
cnds(20).trialfilter.sample = 1;

cnds(21).name = 'D1+ret_S2_D0124';
cnds(21).relfolder = fullfile('SKF38393','retention','smpl');
cnds(21).trialfilter.drug = 'SKF38393';
cnds(21).trialfilter.drug_mode = 'retention';
cnds(21).trialfilter.sample = 2;

cnds(22).name = 'D1+ret_S4_D0124';
cnds(22).relfolder = fullfile('SKF38393','retention','smpl');
cnds(22).trialfilter.drug = 'SKF38393';
cnds(22).trialfilter.drug_mode = 'retention';
cnds(22).trialfilter.sample = 4;

cnds(23).name = 'D1+ret_S124_D124';
cnds(23).relfolder = fullfile('SKF38393','retention','dstr');
cnds(23).trialfilter.drug = 'SKF38393';
cnds(23).trialfilter.drug_mode = 'retention';
cnds(23).trialfilter.distractor = [1 2 4];

cnds(24).name = 'D1+ret_S124_D0';
cnds(24).relfolder = fullfile('SKF38393','retention','dstr');
cnds(24).trialfilter.drug = 'SKF38393';
cnds(24).trialfilter.drug_mode = 'retention';
cnds(24).trialfilter.distractor = 0;

cnds(25).name = 'D1+ret_S124_D1';
cnds(25).relfolder = fullfile('SKF38393','retention','dstr');
cnds(25).trialfilter.drug = 'SKF38393';
cnds(25).trialfilter.drug_mode = 'retention';
cnds(25).trialfilter.distractor = 1;

cnds(26).name = 'D1+ret_S124_D2';
cnds(26).relfolder = fullfile('SKF38393','retention','dstr');
cnds(26).trialfilter.drug = 'SKF38393';
cnds(26).trialfilter.drug_mode = 'retention';
cnds(26).trialfilter.distractor = 2;

cnds(27).name = 'D1+ret_S124_D4';
cnds(27).relfolder = fullfile('SKF38393','retention','dstr');
cnds(27).trialfilter.drug = 'SKF38393';
cnds(27).trialfilter.drug_mode = 'retention';
cnds(27).trialfilter.distractor = 4;

% SCH23390 (D1 antagonist)
    % ejection
cnds(28).name = 'D1-ej_S124_D0124';
cnds(28).relfolder = fullfile('SCH23390','ejection');
cnds(28).trialfilter.drug = 'SCH23390';
cnds(28).trialfilter.drug_mode = 'ejection';

cnds(29).name = 'D1-ej_S1_D0124';
cnds(29).relfolder = fullfile('SCH23390','ejection','smpl');
cnds(29).trialfilter.drug = 'SCH23390';
cnds(29).trialfilter.drug_mode = 'ejection';
cnds(29).trialfilter.sample = 1;

cnds(30).name = 'D1-ej_S2_D0124';
cnds(30).relfolder = fullfile('SCH23390','ejection','smpl');
cnds(30).trialfilter.drug = 'SCH23390';
cnds(30).trialfilter.drug_mode = 'ejection';
cnds(30).trialfilter.sample = 2;

cnds(31).name = 'D1-ej_S4_D0124';
cnds(31).relfolder = fullfile('SCH23390','ejection','smpl');
cnds(31).trialfilter.drug = 'SCH23390';
cnds(31).trialfilter.drug_mode = 'ejection';
cnds(31).trialfilter.sample = 4;

cnds(32).name = 'D1-ej_S124_D124';
cnds(32).relfolder = fullfile('SCH23390','ejection','dstr');
cnds(32).trialfilter.drug = 'SCH23390';
cnds(32).trialfilter.drug_mode = 'ejection';
cnds(32).trialfilter.distractor = [1 2 4];

cnds(33).name = 'D1-ej_S124_D0';
cnds(33).relfolder = fullfile('SCH23390','ejection','dstr');
cnds(33).trialfilter.drug = 'SCH23390';
cnds(33).trialfilter.drug_mode = 'ejection';
cnds(33).trialfilter.distractor = 0;

cnds(34).name = 'D1-ej_S124_D1';
cnds(34).relfolder = fullfile('SCH23390','ejection','dstr');
cnds(34).trialfilter.drug = 'SCH23390';
cnds(34).trialfilter.drug_mode = 'ejection';
cnds(34).trialfilter.distractor = 1;

cnds(35).name = 'D1-ej_S124_D2';
cnds(35).relfolder = fullfile('SCH23390','ejection','dstr');
cnds(35).trialfilter.drug = 'SCH23390';
cnds(35).trialfilter.drug_mode = 'ejection';
cnds(35).trialfilter.distractor = 2;

cnds(36).name = 'D1-ej_S124_D4';
cnds(36).relfolder = fullfile('SCH23390','ejection','dstr');
cnds(36).trialfilter.drug = 'SCH23390';
cnds(36).trialfilter.drug_mode = 'ejection';
cnds(36).trialfilter.distractor = 4;
    % retention
cnds(37).name = 'D1-ret_S124_D0124';
cnds(37).relfolder = fullfile('SCH23390','retention');
cnds(37).trialfilter.drug = 'SCH23390';
cnds(37).trialfilter.drug_mode = 'retention';

cnds(38).name = 'D1-ret_S1_D0124';
cnds(38).relfolder = fullfile('SCH23390','retention','smpl');
cnds(38).trialfilter.drug = 'SCH23390';
cnds(38).trialfilter.drug_mode = 'retention';
cnds(38).trialfilter.sample = 1;

cnds(39).name = 'D1-ret_S2_D0124';
cnds(39).relfolder = fullfile('SCH23390','retention','smpl');
cnds(39).trialfilter.drug = 'SCH23390';
cnds(39).trialfilter.drug_mode = 'retention';
cnds(39).trialfilter.sample = 2;

cnds(40).name = 'D1-ret_S4_D0124';
cnds(40).relfolder = fullfile('SCH23390','retention','smpl');
cnds(40).trialfilter.drug = 'SCH23390';
cnds(40).trialfilter.drug_mode = 'retention';
cnds(40).trialfilter.sample = 4;

cnds(41).name = 'D1-ret_S124_D124';
cnds(41).relfolder = fullfile('SCH23390','retention','dstr');
cnds(41).trialfilter.drug = 'SCH23390';
cnds(41).trialfilter.drug_mode = 'retention';
cnds(41).trialfilter.distractor = [1 2 4];

cnds(42).name = 'D1-ret_S124_D0';
cnds(42).relfolder = fullfile('SCH23390','retention','dstr');
cnds(42).trialfilter.drug = 'SCH23390';
cnds(42).trialfilter.drug_mode = 'retention';
cnds(42).trialfilter.distractor = 0;

cnds(43).name = 'D1-ret_S124_D1';
cnds(43).relfolder = fullfile('SCH23390','retention','dstr');
cnds(43).trialfilter.drug = 'SCH23390';
cnds(43).trialfilter.drug_mode = 'retention';
cnds(43).trialfilter.distractor = 1;

cnds(44).name = 'D1-ret_S124_D2';
cnds(44).relfolder = fullfile('SCH23390','retention','dstr');
cnds(44).trialfilter.drug = 'SCH23390';
cnds(44).trialfilter.drug_mode = 'retention';
cnds(44).trialfilter.distractor = 2;

cnds(45).name = 'D1-ret_S124_D4';
cnds(45).relfolder = fullfile('SCH23390','retention','dstr');
cnds(45).trialfilter.drug = 'SCH23390';
cnds(45).trialfilter.drug_mode = 'retention';
cnds(45).trialfilter.distractor = 4;

fs = 1000;
time = -1:1/fs:3.6;
for i_cnd = 1:numel(cnds)
    cnds(i_cnd).trialfilter.trialerror = 'correct';
    cnds(i_cnd).trialfilter.saturation.time_range = [-0.5 3.1]; 
    cnds(i_cnd).trialfilter.saturation.time = time;
    cnds(i_cnd).trialfilter.saturation.frac_acceptable_outliers = 0.001;
end
