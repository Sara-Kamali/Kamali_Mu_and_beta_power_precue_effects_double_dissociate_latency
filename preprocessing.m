%% ++++ Preprocessing EEG and EMG Data & EEG Decomposition with AMICA +++++
% We have used public finger-pinching dataset from Cho, Hohyun, et al. "EEG datasets for motor imagery brain–computer 
% interface.", GigaScience 6.7 (2017): gix034. Available from: http://gigadb.org/dataset/100295

clc; clear;

% Paths
eeglab_path = 'path to EEGlab';
codes_path = 'path to Matlab codes';
raw_data_path = ' raw data (s_files) path';
dest_path = 'path to save results';
result_path = fullfile(dest_path, 'ans');
addpath(eeglab_path, codes_path, raw_data_path);

% Load EEGLAB
eeglab; close;

% Dataset parameters
subjects = [1,3,4,5,6,9:15,18,19,21:28,30,31,33,35,36,37,39,41:44,46,48,49,50,52];
nsubj = length(subjects);
Taskname = {'movement_right', 'movement_left', 'imagery_right', 'imagery_left'};
good_subjects = [];
good_comps = {};
good_comps_counter = 0;
%% EEG Data Import and Preprocessing Loop
for current_subj = 1:nsubj
    subj = subjects(current_subj);
    subj_file_name = sprintf('s%02d.mat', subj);
    subj_folder_name = sprintf('s%02d', subj);
    
    % Check if subject data file exists
    if ~exist(fullfile(raw_data_path, subj_file_name), 'file')
        fprintf('\n ---- WARNING: %s does not exist. Skipping this subject. ---- \n', subj_file_name);
        continue;
    end
    
    fprintf('\n\n\n---- Importing dataset for %s ----\n\n\n', subj_file_name);
    
    % Create subject-specific directory for EEG data
    subj_eeg_dir = fullfile(dest_path, subj_folder_name);
    if ~exist(subj_eeg_dir, 'dir')
        mkdir(subj_eeg_dir);
    end
    
    % Load raw EEG data
    eeg_data = load(fullfile(raw_data_path, subj_file_name), '-mat');
    eeg_data = eeg_data.eeg;
    merged_data = [eeg_data.(Taskname{1}), eeg_data.(Taskname{2})];

    % Create EEG structure
    EEG = pop_importdata('dataformat', 'matlab', 'nbchan', 0, 'data', merged_data, 'xmin', 0);
    EEG.srate = eeg_data.srate;
    EEG.subject = subj_file_name;
    EEG.setname = sprintf('%s and %s merged', Taskname{1}, Taskname{2});

    % High-pass filter
    f_low = 1;
    EEG = pop_eegfiltnew(EEG, 'locutoff', f_low, 'plotfreqz', 0);

    % Set channel locations
    EEG.chanlocs = channel_locator(eeg_data.senloc);

    % Clean line noise
    for ii = 1:3
        EEG = pop_cleanline(EEG, 'bandwidth', 2, 'chanlist', 1:EEG.nbchan, ...
            'linefreqs', 50, 'newversion', 0, 'winsize', 7, 'winstep', 7);
    end

    % ASR-based cleaning
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion', 'off', 'ChannelCriterion', 'off', ...
        'LineNoiseCriterion', 'off', 'Highpass', 'off', 'BurstCriterion', 'off', ...
        'WindowCriterion', 'off', 'Distance', 'Euclidian', 'WindowCriterionTolerances', [-Inf 7]);

    % Extract EMG channels
    EMG_data = pop_select(EEG, 'nochannel', 1:64);
    % Exclude EMG channels, prepare EEG structure, and epoch data
    EEG = pop_select(EEG, 'nochannel', 65:68);
    % Fix center of the head model
    EEG = pop_chanedit(EEG, 'eval', 'chans = pop_chancenter( chans, [],[]);');
    % Make temporary records to avoid loss of results so far
    cd(dest_path);delete('tempEEG.mat');
    pop_saveset(EEG, 'filename', 'tempEEG.set', 'savemode', 'twofiles', 'filepath', dest_path);
    EEG = pop_loadset('tempEEG.set');

    % Run ASR to clean the data and reconstract the bad segments and remove bad channels
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',4,'ChannelCriterion',0.6,...
        'LineNoiseCriterion',4,'Highpass','off','asrrej',0,'BurstRejection','off',...
        'BurstCriterion',20,'WindowCriterion','off','Distance','Euclidian',...
        'WindowCriterionTolerances',[-Inf 7] );

    % Average reference EEG channels
    EEG = pop_reref(EEG, []);

    % Setup event structure and epoch trials
    pnt = size(EEG.data, 2) / (2 * eeg_data.n_movement_trials);
    EEG.event = event_struct(pnt, EEG.times, eeg_data.n_movement_trials);
    EEG.pnts = size(EEG.data, 2) / (2 * eeg_data.n_movement_trials);
    EEG = pop_editset(EEG, 'pnts', [EEG.pnts], 'run', []);

    % Reject bad trials based on joint probability
    EEG = pop_jointprob(EEG, 1, 1:EEG.nbchan, 5, 5, 1, 1, 1, [], 0);
    good_eeg_trials = find(EEG.reject.rejjp == 0);

    % Hand change detection
    EEG.Hand_change_trial_ind = detect_hand_change(EEG);

    % Save EEG in a temporary file
    cd(dest_path);delete('tempEEG.mat');
    pop_saveset(EEG,'filename','tempEEG.set','savemode','twofiles', 'filepath',dest_path);
    EEG=pop_loadset('tempEEG.set');


    % EMG data preprocessing
    % Next steps aim to clean EMG and find EMG onset time and the trials with good EMG
    % recordings and remove the rest of trials both for EMG and EEG data

    % Epoch EMG data, enter trials info
    EMG_data.pnts=EEG.pnts;
    EMG_data = pop_editset(EMG_data, 'pnts', [EMG_data.pnts], 'run', []);
    fs=EEG.srate;
    time_vec=0:1/fs:EEG.xmax;
    t_cue=2;t_end=5;% Time of go cue and end of the movement 
    t_start=find(time_vec>t_cue,1);t_end=find(time_vec>=t_end,1);
    t_800=find(time_vec>=.8,1);% Start of the time-window for evaluation of the precue signals quality

     % Extract EMG onset times
    [bipolar_emg, emg_onset, good_emg_trials, emg_qualty] = ...
        emg_onset_detector(EMG_data, good_eeg_trials, t_start, t_end, t_800, time_vec);
    % Save EMG results
    save(fullfile(subj_eeg_dir, sprintf('EMG_analysis_results_s%s', num2str(subj))), ...
        'bipolar_emg', 'emg_onset', 'good_emg_trials', 'emg_qualty', 'Hand_change_trial_ind');

    % Create new directory to save the IC rersults
    amica_output_dir='amica_out';mkdir(subj_eeg_dir,amica_output_dir);
    outdir_path=sprintf('%s\\%s',subj_eeg_dir,amica_output_dir);
    % ICA decomposition with AMICA
    EEG=pop_runamica(EEG,'num_mod',1,'pcakeep',EEG.nbchan - 1,'outdir',outdir_path);

    % Save EEG in a temporary file
    cd(dest_path);delete('tempEEG.mat');
    pop_saveset(EEG,'filename','tempEEG.set','savemode','twofiles', 'filepath',dest_path);
    EEG=pop_loadset('tempEEG.set');
   
    % Label ICs
    EEG = pop_iclabel(EEG, 'default');
    % Remove trials with bad EMG from EEG
    EEG = pop_rejepoch(EEG, setdiff(1:EEG.trials, good_emg_trials), 0);
    
    % Source localization (MNI setting for dipfit)
    hdmfile=sprintf('%s\\plugins\\dipfit\\standard_BEM\\%s',eeglab_path,'standard_vol.mat');
    mrifile=sprintf('%s\\plugins\\dipfit\\standard_BEM\\%s',eeglab_path,'standard_mri.mat');
    chanfile=sprintf('%s\\plugins\\dipfit\\standard_BEM\\%s',eeglab_path,'elec\\standard_1020.elc');
    EEG =pop_dipfit_settings( EEG, 'hdmfile',hdmfile,'mrifile',mrifile,'chanfile',chanfile,...
        'coordformat','MNI','chansel', 1:EEG.nbchan );
    % Coregistr channels to fit the electrodes to the head model for dipol analysis
    [locs,EEG.dipfit.coord_transform] = coregister(EEG.chanlocs,EEG.dipfit.chanfile,...
        'chaninfo1', EEG.chaninfo,'mesh',EEG.dipfit.hdmfile,'warpmethod','rigidbody','warp','auto',...
        'manual','off');

    % Save EEG in a temporary file
    cd(dest_path);delete('tempEEG.mat');
    pop_saveset(EEG,'filename','tempEEG.set','savemode','twofiles', 'filepath',dest_path);
    EEG=pop_loadset('tempEEG.set');
    % Run multift to automatically fit the size of electrodes with the model
    EEG = pop_multifit(EEG, [] ,'threshold',15,'rmout','on','dipplot','on','plotopt',{'normlen','on'});

    % Run Talairach to find Brodmann area of each IC
    EEG=talLookup(EEG,[],'C:\Users\SARA\Documents\MATLAB_files\codes\');
    %talLookup function is EEGlab function modified by Seyed Yahya Shirazi,
    % BRaIN Lab, UCF,email: shirazi@ieee.org available on github

    % Find the components that are brain/eye components with rv<15%
    IC_label_probability=.60;dipole_residual=.15;
    EEG=dipfit_criteria(EEG,IC_label_probability,dipole_residual);

    % Update good subject list based on EMG and dipoles criteria
    if strcmp(emg_qualty, 'good') && numel(EEG.components_to_cluster.brain_comps) > 1
        good_subjects = [good_subjects, subj];
        good_comps{end + 1} = EEG.components_to_cluster.good_comps;
        good_comps_counter = good_comps_counter + numel(EEG.components_to_cluster.good_comps);
    end


    % Save final processed data
    pop_saveset(EEG, 'filename', sprintf('processed_merged_RL%s.set', num2str(subj)), ...
        'savemode', 'twofiles', 'filepath', subj_eeg_dir);
    close %closing dipoles plot
end

% Save selected subjects and ICs for study design
cd(result_path);
save('good_subjects.mat', 'good_subjects');
save('good_comps.mat', 'good_comps');


