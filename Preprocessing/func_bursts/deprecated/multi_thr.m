function c = multi_thr(z,min_thr,step,n_preallocate)
% Finds candidate bursts in z-scored power by iteratively lowering a threshold 
% and finding when clusters merge.
% Input:    z           z-scored power
%           min_thr     minimum value for threshold
%           step        step size for lowering threshold
%           n_preall    number of clusters to preallocate memory for    
% Output:   c       list of clusters with properties in columns 
%                   c(:,1)  linear index in z of brightest pixel 
%                   c(:,2)  threshold at which cluster appeared first
%                   c(:,3)  lowest threshold before merge
%                   c(:,4)  x index of bounding box left edge
%                   c(:,5)  y index of bounding box top edge
%                   c(:,6)  bounding box x-width in bins
%                   c(:,7)  bounding box y-height in bins

max_val = max(z(:));

c = zeros(n_preallocate,7);

n_clust = 0;
for t = flip(min_thr:step:max_val);
    % linear index of regions' brightest pixel
    rp = regionprops(z>=t,z,'BoundingBox','MaxIntensity','PixelIdxList');
    num_objects = length(rp);

    % brightest pixel for regions at this threshold
    b_this_t = arrayfun(@(x) find(z==x.MaxIntensity,1,'first'),rp);

    % Among the regions' brightest pixels, is there a new brightest one that is not yet in
    % the cluster list? This is a new cluster.
    new_clust = b_this_t(~ismember(b_this_t,c(:,1)));
    if ~isempty(new_clust)
        c((n_clust+1):(n_clust+numel(new_clust)),:) = horzcat(new_clust, ones(numel(new_clust),1)*t, zeros(numel(new_clust),5));
        n_clust = n_clust+numel(new_clust);
    end

    % any existing cluster lost?
    not_at_this_thr = ~ismember(c(:,1),b_this_t);
    not_yet_merged = c(:,3)==0;
    % set the child clusters to merged
    c(not_at_this_thr&not_yet_merged,3) = t+step;

    %% find which cluster they now belong to and set parent cluster to merged
    % which of the current clusters contains the brightest pixels of those clusters that are not present at this threshold
    old_in_current = arrayfun(@(x) any(ismember(c(not_at_this_thr,1), x.PixelIdxList)), rp);
    parent = b_this_t(old_in_current);
    c(ismember(c(:,1), parent) & not_yet_merged, 3) = t+step;

    % record bounding box for clusters not yet merged
    [~,b_in_c] = ismember(b_this_t,c(:,1));
    relevant = ismember(b_this_t,c(c(:,3)==0,1)); 

    c(b_in_c(relevant),4:end) = cell2mat(arrayfun(@(x) x.BoundingBox,rp(relevant),'uni',0));
end
c = c(1:n_clust,:);
