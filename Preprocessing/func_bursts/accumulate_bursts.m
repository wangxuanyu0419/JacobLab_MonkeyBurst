function [br_b, br_nb] = accumulate_bursts(bspc_vec,n_trl,f,n_t)
% Accumulate bursts within frequency bands across trials of interest. Trials of interest are selected
% using fun.

n_f = numel(f);
% column 1: trials; column 2: freq bands; column 3: times
subs = gpuArray([ ...
                    repmat(kron(uint16(gpuArray.colon(1,1,n_trl)),ones(1,n_f,'uint16','gpuArray')),[1 n_t])'...
                    repmat(f,n_trl*n_t,1)...
                    kron(uint16(gpuArray.colon(1,1,n_t)),ones(1,n_f*n_trl,'uint16','gpuArray'))'...
                    ]);
accm = accumarray(subs,bspc_vec);
% mean across trials
br_b = mean(accm(:,1:end-1,:)>0,1);
br_nb = mean(accm(:,1:end-1,:),1);
