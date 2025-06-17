function trl = trialfun_inclerror(cfg)

% This trial segment function requires the following fields to be specified:
%     - eventvalue: event E to align, e.g. 3 for reward, 25 for sample stim onset
%     - pretrl: time (sec) before E included in analysis
%     - posttrl: time (sec) after E for analysis
%     - triallen: triallength start from E (kind of unnecessary considering pre- and posttrl should have already define the length)
%     - errorcode: use for select trials based on the response correction
%     - stimtype: select trial based on standard/controlled stimulus
%     - sampnum: select trial based on sample numerosity
%     - distnum: select based on distractor numerosity

%% read in header and events
    hdr     = ft_read_header(cfg.dataset); % mainly for sampling frequency
    event   = ft_read_event(cfg.dataset);
    
    stdir = '../Data';
    
    %% event marker codes
    beginTrial          = 9;
    endTrial            = 18;
    startPreTrial       = 15;  % start pre trial period (after fixation onset)
    sampon              = 25;
    sampoff             = 26;
    delay1on            = 33;
    delay1off           = 34;
    diston              = 27;
    distoff             = 28;
    delay2on            = 48;
    delay2off           = 49;
    nonmatchon          = 29;
    nonmatchoff         = 30;
    matchon             = 31;
    matchoff            = 23;
    correct             = 200; % correct trial 
    mistake             = 201; % error trial
    
    %% analysis variables:
    fixedTrialLen  = true;
    preanapad      = round(hdr.Fs * cfg.trialdef.pretrl);
    postanapad     = round(hdr.Fs * cfg.trialdef.posttrl);
    anatriallen    = round(hdr.Fs * cfg.trialdef.triallen) + preanapad + postanapad; % unit from s to num of samples
    eventmark      = cfg.trialdef.eventvalue;
    
    %% convert struct to vector
    % select only specified event types:
    eventsel = event(1);
    stridx = 1;
    if isfield(cfg.trialdef,'eventtype')
        for ix = 1:numel(event)
            if strncmp(event(ix).type, cfg.trialdef.eventtype,7)
                eventsel(stridx) = event(ix);
                stridx = stridx + 1;
            end
        end
    end
    TimeStamps = [eventsel.sample]';
    Marks = [eventsel.value]';
    
    %% select trials:
    % find certain markers within a trial in reference to the beginning
    begidxs = find(Marks == beginTrial);
    begidxs = begidxs(1:3:end); % take the first of 3 repeats
    enddixs = find(Marks == endTrial);
    enddixs = enddixs(3:3:end); % take the last of 3 repeats
    if size(begidxs, 1) > size(enddixs, 1)
        % if PLEXON terminated before CORTEX, remove last incomplete trial
        begidxs = begidxs(1:end-1);
    end
    
    % get trial info
    ctxfilename = [cfg.dataset((end-17):(end-11)),'.mat'];
    load(fullfile(stdir,'spike_nexctx',ctxfilename),'nexctx');
    trlnum = length(nexctx.TrialResponseErrors);
    
    % select trials
    if isfield(cfg.trialdef,'errorcode')
        if isnan(cfg.trialdef.errorcode)
            errorsel = ones(trlnum,1);
        else
            errorsel = nexctx.TrialResponseErrors == cfg.trialdef.errorcode;
            if size(errorsel,2)>1; errorsel = sum(errorsel,2)>0; end % if multiple errorcodes provided, select with OR logic
        end
    else
        error('Field cfg.errorcode not defined');
    end
    
    if isfield(cfg.trialdef,'stimtype') % standard or control trial
        if isnan(cfg.trialdef.stimtype)
            stimsel = ones(trlnum,1);
        else
            stimsel = mod(nexctx.TrialResponseCodes,10) == cfg.trialdef.stimtype;
        end
    end
    
    if isfield(cfg.trialdef,'sampnum') % sample numerosity
        if isnan(cfg.trialdef.sampnum)
            sampsel = ones(trlnum,1);
        else
            sampsel = floor(nexctx.TrialResponseCodes/1000) == cfg.trialdef.sampnum;
        end
    end
    
    if isfield(cfg.trialdef,'distnum') % sample numerosity
        if isnan(cfg.trialdef.distnum)
            distsel = ones(trlnum,1);
        else
            distsel = mod(floor(nexctx.TrialResponseCodes/100),10) == cfg.trialdef.distnum; % the hundreds digits are for distractor, e.g. x2xx
        end
    end
   
    sellog = errorsel & stimsel & sampsel & distsel;
    idxmat = [1:1:trlnum]';
    selidx = idxmat(sellog);
    
    %% initialise and allocate memory for trl-matrix
    k = 1;
    for i = 1:sum(sellog)
        trlidx = selidx(i);
        trialmarks = Marks(begidxs(trlidx):enddixs(trlidx));
        trialstamps = TimeStamps(begidxs(trlidx):enddixs(trlidx));
        if isempty(find(trialmarks==eventmark,1))
            continue
        end
        anabegstamp = trialstamps(trialmarks == eventmark) - preanapad;
        anaendstamp = anabegstamp + anatriallen;
        trl(k,:) = [anabegstamp anaendstamp -preanapad];
        k = k+1;
    end
end


    