function chanlay = get_chan_layout(ax,pattern)
% create 2D  figure by the channel layout pattern, chanlay containing
% circle objects

nchan = numel(pattern); % should be 8 for one region
chanlay = cell(nchan,1);

for ichan = 1:nchan
    loc = pattern{ichan};
    r = 0.4;
    chanlay{ichan} = rectangle(ax,'Position',[loc-r,2*r,2*r],'Curvature',[1 1],'EdgeColor','k');
end
end