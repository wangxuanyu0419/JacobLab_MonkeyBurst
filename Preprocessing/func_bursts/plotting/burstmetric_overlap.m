function burstmetric_overlap(mean_fig_dir, mintrl)
% Overlaps plots for mean burst metrics for sample or distractor numerosities and saves plots.
% Depends on existing mean plots.
%
% Input
% -----
% mean_fig_dir: struct (from function dir)
%   Struct from function DIR that contains filepath information for *mean*.fig files that are the source
%   for the overlap plots.
% mintrl: double
%   Minimum number of trials an electrode must contain for it to be part of the mean trace.

% mapping of freq to colormap
fb = containers.Map({'04-10Hz','20-35Hz','50-90Hz'},{'Blues','Oranges','Greens'});
% unique folders
folders = unique(arrayfun(@(x) x.folder, mean_fig_dir, 'uni', 0));
% find where numerosity is modulated (match for folder name 'smpl' or name 'dstr')
folders = folders(cellfun(@(x) ~isempty(regexp(x,'(smpl|dstr)')),folders));

% iterate over folders, open corresponding figures and overlap numerosity plots
for condition = folders'
    condition = condition{:};
    % find mean files where either only sample or distractor was modulated
    f = dir(fullfile(condition,'*mean*.fig')); % these should be sorted by numerosity
    f = f(arrayfun(@(x) ~isempty(regexp(x.name,'(D\d{1}mean|S\d{1}_)')),f));
    figs = gobjects(numel(f),1);
    for i = 1:numel(f)
        figs(i) = openfig(fullfile(f(i).folder,f(i).name));
        % exclude electrodes with too few trials
        meanburstmetric_plot_mintrl(figs(i),mintrl);
        % append numerosity to DisplayName
        br = findobj(figs(i),'-regexp','DisplayName','Hz');
        num = regexp(f(i).name,'(D\d{1}mean|S\d{1}_)');
        num = f(i).name(num:num+1);
        for i_l = 1:numel(br)
            br(i_l).DisplayName = sprintf('%s_{%s}',br(i_l).DisplayName, num);
        end
    end

    overlap = figure('Position', figs(1).Position);
    main_ax_template = findobj(figs(1),'-regexp','Tag','mean');
    ax = axes(overlap, ...
        'Position', main_ax_template.Position,...
        'XLim', main_ax_template.XLim,...
        'YLim', main_ax_template.YLim,...
        'XLabel', main_ax_template.XLabel,...
        'YLabel', main_ax_template.YLabel,...
        'Title', main_ax_template.Title);
    
    % copy lines for one frequency band
    for i_fb = fb.keys
        br = copyobj(findobj(figs,'-regexp','DisplayName',i_fb{:}),ax);
        % reserve lightest cue for distractor == 0, i.e. num==1 should always be the same for sample and distractor
        if any(contains(get(br,'DisplayName'),'D0'))
            c = brewermap(numel(br), fb(i_fb{:}));
        else
            c = brewermap(numel(br)+1, fb(i_fb{:}));
            c = c(2:end,:);
        end
        arrayfun(@(x) set(br(x),'Color',c(x,:)), 1:numel(br));
    end

    % add stimulus presentation markers
    arrayfun(@(x) line(ax,ones(2,1)*x,ylim(ax),'LineStyle','--'), [0 0.5 1.5 2 3])

    legend(findobj(ax.Children,'-regexp','DisplayName','Hz'), ...
        'NumColumns', fb.Count, ...
        'Location', 'Best');

    % copy text box string and prepend condition strings
    tb_template = findall(figs(1),'Type','TextBox');
    tb = annotation('TextBox',[0 0 1 1],'String',tb_template.String);
    tb.String = vertcat(arrayfun(@(x) regexp(x.name,'\w*mean','match'),f),...
        tb.String(2:end));
    tb.String = strrep(tb.String,'_','\_');
    tb.String = strrep(tb.String,'trials: ', sprintf('trials (n>=%d)', mintrl));

    % save
    savefig(overlap,...
        fullfile(condition, '.overlap_num.fig'),...
        'compact');
    % print eps if not in headless mode
    if isempty(java.lang.System.getProperty('java.awt.headless'))
        print(overlap,...
            fullfile(condition, 'overlap_num'),...
            '-depsc');
    end

    close all
end
