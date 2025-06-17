function candidates = find_burstcandidates(cfg, pow)
% Finds burst candidates and extracts properties: maximum amplitude, frequency index of maximum
% value, time index of maximum value, frequency width in pixels of bounding box, time with in 
% pixels of bounding box, fit region pixel index list.
% Local maxima are first smoothed by image dilation. Individual burst regions are found using the
% watershed algorithm on the negative of the dilated image. Watershed lines are imposed on the
% thresholded image and burst candidates are extracted from the connected components of this 
% segmented image.
% The use of 4-connected watershed and connected components allows to obtain slanted watershed
% lines.
%
% Input
% -----
% cfg: struct
%   imdilate_strel: binary matrix or output from "strel"
%       Structuring element for image dilation. Image dilation is used to remove
%       very close peaks by morphological dilation. 'Very close' is defined by this
%       option. Default: strel('square',3) removes peaks in an 8-connected neighbourhood.
%   threshold: double scalar
%       Defines threshold at which power is considered to be strong enought to be deemed
%       burst-like.
%   conn: double scalar
%       Defines connectivity for "watershed" and "bwconncomp".
% pow: double matrix
%   Power with dimensions frequency-by-time. Default: 2.

if ~isfield(cfg,'imdilate_strel')
    cfg.imdilate_strel = strel('square',3);
end
if ~isfield(cfg,'threshold')
    cfg.threshold = 2;
end
if ~isfield(cfg, 'conn')
    cfg.conn = 4;
else
    if ~ismember(cfg.conn,[4 8])
        error('Connectivity for 2D images can only be 4 or 8.')
    end
end

% if NaN exists in pow, substitute with zero
pow(isnan(pow)) = 0;

% blur very close maxima and segment image so that subcomponents can be extracted
segmented = watershed(-imdilate(pow,cfg.imdilate_strel), cfg.conn);

% subsegment connected components
pow_thr_seg = pow;
pow_thr_seg(pow<cfg.threshold) = 0;
pow_thr_seg(segmented==0) = 0;
cc = bwconncomp(pow_thr_seg, cfg.conn);

% extract
rp = regionprops(cc, pow_thr_seg, {'BoundingBox' 'MaxIntensity'});
amp = arrayfun(@(x) x.MaxIntensity,rp, 'uni', 0);
[f, t] = cellfun(@(x) find(pow==x,1), amp, 'uni', 0); % may be problematic, very rare cases the exact same value appear more than once
tw = arrayfun(@(x) x.BoundingBox(3),rp, 'uni', 0);
fw = arrayfun(@(x) x.BoundingBox(4),rp, 'uni', 0);
pidx = cc.PixelIdxList;
candidates = struct('amp', amp', 'f', f', 't', t', 'tw', tw', 'fw', fw', 'pidx', pidx); 
