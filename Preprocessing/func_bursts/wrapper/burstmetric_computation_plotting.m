function burst_metric_computation_plotting(f,burst_metric_accumulator,fun_burstprop,path_to_conditions,figfolder,figtext,f_bands,measures,stats)
% Computes and plots burst metric.
% Creates figures for plotting
%   burst metric distribution
%   burst metric mean across electrodes
% Per figure creates burst metric axes and scatter axes. Scatter axes plots number of bursts vs. number of trials per electrode
% Adds metainfo and decoration.
%
% Input
% -----
% f: struct (from function dir)
%   Contains paths to individual electrode's mat files. These matfiles must contain a FieldTrip-like struct with trialinfo that contains burst fit values.
% burst_metric_accumulator: function handle
%   Handle to function that accumulates the desired burst metric across trials.
%   Function takes input arguments 'brst_oi' (cell array containing burst fit parameters per trial), time (trial time points) and fun_burstprop.
% fun_burstprop: function handle
%   Handle to function that computes desired burst metric per burst.
% path_to_conditions: str
%   Path to condition specification that is used for trial filtering.
% figfolder: str
%   Path to output folder in which figures are saved
% figtext: str
%   Text to show at the left side of figures
% f_bands: double matrix
%   n-by-2 matrix with frequency ranges for which to compute burst metric.
% measures: struct
%   Must contain fields
%       text: string to be shown in plot annotation
%       subfold: subfolder in which to save plots.
%       ylim: ylim for the plots.
% stats: struct
%   Strings for plots. First element is for distribution plot, second for mean across electrodes. Must contain fields
%       append: to be appended to plot filename
%       tag: plot tag and title

run(path_to_conditions);
n_elec = numel(f);
n_cnd = numel(cnds);
n_time = numel(time); % time from conditions specification
n_measures = length(measures);
n_stats = length(stats);
elec_labels = arrayfun(@(x) erase(x.name, '.mat'), f, 'uni', 0);
n_frq = size(f_bands,1);

for i_cnd = 1:length(cnds)
    metric = cell(n_elec, 1);
    ntrl = cell(n_elec, 1);
    nbrst = cell(n_elec, 1);

    cfg = [];
    cfg.trialfilter = cnds(i_cnd).trialfilter;
    cfg.min_cycle = 1;
    cfg.f_bands = f_bands;
    cfg.time = time;
    cfg.burst_metric_accumulator = burst_metric_accumulator;
    cfg.fun_burstprop = fun_burstprop;
    cfg.n_measures = n_measures;

    parfor i_elec = 1:n_elec
        [metric{i_elec}, ntrl{i_elec}, nbrst{i_elec}] = burstmetric_computation(cfg, fullfile(f(i_elec).folder,f(i_elec).name));
    end
    metric = cellfun(@(x) reshape(x, [1 size(x)]), metric, 'uni', 0);
    metric = vertcat(metric{:});
    nbrst = cellfun(@(x) reshape(x, [1 size(x)]), nbrst, 'uni', 0);
    nbrst = vertcat(nbrst{:});
    ntrl = cell2mat(ntrl);

    
    % plotting
    gobj = gobjects(n_measures,3,n_stats);
    for i_measure = 1:n_measures
        for i_stats = 1:n_stats
            gobj(i_measure,1,i_stats) = figure('Position',[905 -881 1280 723],'Visible',false);
            gobj(i_measure,2,i_stats) = axes(gobj(i_measure,1,i_stats),'Position', [0.3 0.11 0.655 0.815], 'NextPlot', 'add', 'Tag', stats(i_stats).tag);
            gobj(i_measure,3,i_stats) = axes(gobj(i_measure,1,i_stats), 'Position', [0.05 0.11 0.2 0.2], 'Tag', 'count');
        end
    end
    for i_measure = 1:n_measures
        for i_frq = 1:n_frq
            clear userdata
            
            % individual electrodes
            l = plot(gobj(i_measure,2,1),...
                    time, squeeze(metric(:,i_measure,i_frq,:)),...
                    'Color',[gobj(i_measure,2,1).ColorOrder(i_frq,:) 0.1],...
                    'DisplayName', sprintf('%02d-%02dHz', f_bands(i_frq,:)));
            arrayfun(@(x,y) set(x,'Tag',y{:}), l, elec_labels);

            % mean
            userdata.metric = squeeze(metric(:,i_measure,i_frq,:));
            userdata.ntrl = ntrl;
            userdata.nbrst = nbrst(:,i_frq);
            userdata.label = elec_labels;
            l = plot(gobj(i_measure,2,2),...
                    time, mean(userdata.metric,1,'omitnan'),...
                    'Color',gobj(i_measure,2,2).ColorOrder(i_frq,:),...
                    'DisplayName', sprintf('%02d-%02dHz', f_bands(i_frq,:)),...
                    'UserData',userdata ...
                    );
            add_sd_patch(l,std(userdata.metric,[],1,'omitnan'));
        end
    end
    % trial count vs burst count
    for ax = findobj(gobj,'flat','Tag','count')'
        for i_frq = 1:n_frq
            ax.NextPlot = 'add';
            scatter(ax,ntrl,nbrst(:,i_frq),'Marker','.','MarkerEdgeColor',ax.ColorOrder(i_frq,:));
        end
        ax.Tag = 'count';
        line(ax,zeros(2,1),ylim(ax),'Tag','mintrl','Color','red','LineStyle','--');
        line(ax,xlim(ax),zeros(2,1),'Tag','minbrst','Color','red','LineStyle','--');
    end
    % meta information, decoration, print/save
    for i_measure = 1:n_measures
        for i_stats = 1:n_stats
            annotation(gobj(i_measure,1,i_stats),...
                'textbox',[0 0 1 1],...
                'String',...
                horzcat(strrep(cnds(i_cnd).name,'_','\_'), ...
                                newline, measures(i_measure).text, ...
                                figtext));

            xlim(gobj(i_measure,2,i_stats), [-0.5 3.1]);
            xlabel(gobj(i_measure,2,i_stats), 'time from sample_{on}[s]');
            ylim(gobj(i_measure,2,i_stats), measures(i_measure).ylim);
            ylabel(gobj(i_measure,2,i_stats), measures(i_measure).text);
            title(gobj(i_measure,2,i_stats), gobj(i_measure,2,i_stats).Tag);
            % trial epoch lines and legends
            arrayfun(@(x) line(gobj(i_measure,2,i_stats), ones(2,1)*x, [0 1],'LineStyle','--','Color','k'),[0 0.5 1.5 2 3]);
            obj4legend = findobj(gobj(i_measure,2,i_stats).Children,'-regexp','DisplayName','Hz');
            legend(obj4legend(end-2:end));

            xlabel(gobj(i_measure,3,i_stats), 'n_{trials}');
            ylabel(gobj(i_measure,3,i_stats), 'n_{bursts}');
            title(gobj(i_measure,3,i_stats), gobj(i_measure,3,i_stats).Tag);

            % save figure
            this_folder = fullfile(...
                            figfolder,...
                            measures(i_measure).subfold,...
                            cnds(i_cnd).relfolder);
            if exist(this_folder,'dir') == 0
                mkdir(this_folder);
            end
            savefig(gobj(i_measure,1,i_stats),...
                fullfile(this_folder,...
                        sprintf('.%s%s.fig',cnds(i_cnd).name,stats(i_stats).append)),...
                'compact');
            % print eps if not in headless mode
            if isempty(java.lang.System.getProperty('java.awt.headless'))
                print(gobj(i_measure,1,i_stats),...
                    fullfile(this_folder,...
                        sprintf('%s%s',cnds(i_cnd).name,stats(i_stats).append)),...
                    '-depsc');
            end
        end
    end
    close all
end
