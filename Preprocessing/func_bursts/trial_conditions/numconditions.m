% condition definitions for normal numerosity dataset
cnds = struct;
cnds(1).name = 'S1234_D01234';
cnds(1).relfolder = '';

cnds(2).name = 'S1_D01234';
cnds(2).relfolder = 'smpl';
cnds(2).trialfilter.sample = 1;

cnds(3).name = 'S2_D01234';
cnds(3).relfolder = 'smpl';
cnds(3).trialfilter.sample = 2;

cnds(4).name = 'S3_D01234';
cnds(4).relfolder = 'smpl';
cnds(4).trialfilter.sample = 3;

cnds(5).name = 'S4_D01234';
cnds(5).relfolder = 'smpl';
cnds(5).trialfilter.sample = 4;

cnds(6).name = 'S1234_D124';
cnds(6).relfolder = 'dstr';
cnds(6).trialfilter.distractor = [1 2 4];

cnds(7).name = 'S1234_D0';
cnds(7).relfolder = 'dstr';
cnds(7).trialfilter.distractor = 0;

cnds(8).name = 'S1234_D1';
cnds(8).relfolder = 'dstr';
cnds(8).trialfilter.distractor = 1;

cnds(9).name = 'S1234_D2';
cnds(9).relfolder = 'dstr';
cnds(9).trialfilter.distractor = 2;

cnds(10).name = 'S1234_D3';
cnds(10).relfolder = 'dstr';
cnds(10).trialfilter.distractor = 3;

cnds(11).name = 'S1234_D4';
cnds(11).relfolder = 'dstr';
cnds(11).trialfilter.distractor = 4;

fs = 1000;
time = -1:1/fs:3.6;
for i_cnd = 1:numel(cnds)
    cnds(i_cnd).trialfilter.trialerror = 'correct';
    cnds(i_cnd).trialfilter.saturation.time_range = [-0.5 3.1]; 
    cnds(i_cnd).trialfilter.saturation.time = time;
    cnds(i_cnd).trialfilter.saturation.frac_acceptable_outliers = 0.001;
end
