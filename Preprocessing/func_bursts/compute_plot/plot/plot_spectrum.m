function fig = plot_spectrum(cfg, z)

    fig = figure('Position',[905 -881 1280 723], 'Visible', true);
    ax = axes(fig,'Position', [0.3 0.11 0.655 0.815]);

    imagesc(ax,...
        cfg.x.values, ...
        cfg.y.values, ...
        z);

    ax.YDir = 'normal';
    c = colorbar(ax);
    c.Label.String = cfg.colorbar.string;

    % trial epoch lines
    arrayfun(@(x) line(ax, ones(2,1)*x, ylim(ax),'LineStyle','--','Color','w'),[0 0.5 1.5 2 3]);

    xlabel(ax, cfg.x.label);
    ylabel(ax, cfg.y.label);
    annotation(fig,...
        'textbox',[0 0 1 1],...
        'String', cfg.annotation.string);

    % save
    [folder, name] = fileparts(cfg.save.fullpath);
    mkdir(folder);
    savefig(fig, fullfile(folder, sprintf('.%s.fig', name)), 'compact');
    print(fig, sprintf('%s', cfg.save.fullpath), '-depsc')
