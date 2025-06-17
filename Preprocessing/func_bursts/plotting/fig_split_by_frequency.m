function figs = fig_split_by_frequency(fig, frq)
% Returns split figures in which only the lines for the specified frequency band is visible
%
% Input
% -----
% fig: figure
%   Figure containing lines with DisplayNames of frequency bands.
% frq: struct
%   band: 2-element vector of frequency band in format [low high].
%   ylim: 2-element vector of ylims for the bands specified in 'band'
%
% Output
% ------
% figs: gobjects
%   Numel(frq)-element vector of figures split by frequency.

n_frq = numel(frq);
ln = findobj(fig, '-regexp', 'DisplayName', 'Hz');
set(ln, 'Visible', false);
figs = arrayfun(@(x) figure('Position',fig.Position, 'Tag', sprintf('%02d-%02d', frq(x).band)),1:n_frq);

for i_frq = 1:n_frq
    ln_oi = findobj(ln,'-regexp', 'DisplayName', sprintf('(%02d-%02d)', frq(i_frq).band));
    set(ln_oi,'Visible',true);
    set(ln_oi(1).Parent, 'YLim',  frq(i_frq).ylim);
    set(findobj(fig,'Type','Legend'),'Location','best');
    copyobj(fig.Children,figs(i_frq));
    set(ln_oi,'Visible',false);
end
