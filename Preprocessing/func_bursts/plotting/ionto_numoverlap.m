% Script that generates plots that directly compare ejection and retention burst metric traces.
% Uses existing plots and copies lines.

% colors
c = zeros(4,3,3);
% 04-10 Hz
c(:,:,1) = brewermap(4,'blues');
% 20-35 Hz
c(:,:,2) = brewermap(4,'oranges');
% 50-90 Hz
c(:,:,3) = brewermap(4,'greens');

folders_search = {'/mnt/share/DANIEL/IONTOPHORESIS/_plots/bursts/addASLT_3_30/190830-burst_rate/accum/**' ...
    '/mnt/share/DANIEL/IONTOPHORESIS/_plots/bursts/addASLT_3_30/190830-burst_rate/binary/**'...
    '/mnt/share/DANIEL/IONTOPHORESIS/_plots/bursts/addASLT_3_30/190924-burst_width/sec/**'...
    '/mnt/share/DANIEL/IONTOPHORESIS/_plots/bursts/addASLT_3_30/190924-burst_width/cyc/**'...
    };
for folder_search = folders_search
    folder_search = folder_search{1};
    ej = dir(fullfile(folder_search,'*ej*mean_elec.fig'));
    append_to_name = {'ej','ret'};
    for i_file = 1:length(ej);
        fig = gobjects(2,1);
        fig(1) = openfig(fullfile(ej(i_file).folder,ej(i_file).name));
        ret = dir(fullfile(folder_search,strrep(ej(i_file).name,'ej','ret')));
        fig(2) = openfig(fullfile(ret.folder,ret.name));
        delete(findobj('type','patch'));
        delete(findobj('type','axes','tag','count'));
        ax = findobj(fig(1),'type','axes');

        % append to DisplayNames so that legend is informative
        for i_fig = 1:length(fig)
            l = findobj(fig(i_fig),'type','line','-regexp','displayname','.');
            for i_line = 1:length(l)
                l(i_line).DisplayName = [l(i_line).DisplayName '_{' append_to_name{i_fig} '}'];
            end
        end

        % copy lines and change colors
        co = copyobj(flip(l),ax);
        set(co, {'Color'}, squeeze(num2cell(c(2,:,:),2)));
        % add to annotation
        tb = findall(fig(1),'Type','TextBox');
        tb.String = vertcat(tb.String(1), strrep(tb.String(1),'ej','ret'), tb.String(2:end));
        % save
        folder_save = ej(i_file).folder(1:strfind(ej(i_file).folder,'ejection')-1);
        print(fig(1),fullfile(folder_save,strrep(ej(i_file).name(2:end-4),'ej','ejret')),'-depsc');
        savefig(fig(1),fullfile(folder_save,strrep(ej(i_file).name,'ej','ejret')),'compact');

        close all
    end
end
