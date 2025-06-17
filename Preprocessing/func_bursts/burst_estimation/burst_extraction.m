function burst_extraction(f_path,f_name,outpath)
    f_title = f_name(1:end-4);
    load(fullfile(f_path,f_name));
    fprintf('Now start: %s\n',f_title);
    
    data_burst = addburst(data_norm);
    fprintf('Burst extraction done: %s\n',f_title);

    save(fullfile(outpath,[f_title '.mat']),'data_burst','-mat');
    fprintf('Save file done: %s\n',f_title);
end