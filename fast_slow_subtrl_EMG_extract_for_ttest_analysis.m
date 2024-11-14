% This script creates a balanced pool of fast and slow subjects/trials for trait and state-based 
% EMG t-test analysis.
clc; clear;

% Set default plot properties
set(groot, 'DefaultAxesFontSize', 14, 'DefaultLineLineWidth', 2, 'DefaultTextFontSize', 14);

% Define file paths and add required directories
file_path = 'data path';
addpath(file_path);

% Load initial data
load('fast_slow_subject_ind.mat'); % Fast and slow subject/trial and EMG onset data
load('fast_slow_subtrl_data.mat'); % Cluster information
load('MS_cls_info.mat');

% Set parameters
fast_slow_subs = [fast_slow_data.subject];
all_subjects = [3, 4, 5, 9, 13, 14, 19, 22, 23, 25, 27, 30, 35, 36, 46, 48, 49, 50, 52];
nsubj = length(all_subjects);

% Determine minimum number of trials across subjects for balanced selection
min_substrl_len = min(arrayfun(@(s) length(s.emg_onsets), fast_slow_data));
min_trlstrl_len = min(arrayfun(@(s) min(length(s.fastTrls), length(s.slowTrls)), fast_slow_data));

% Define variables to initialize
variables = {'fast_subs','slow_subs','fast_subs_emgonest','slow_subs_emgonest', ...
             'fast_trls', 'slow_trls','fast_trls_emgonsets','slow_trls_emgonsets'};
for var = variables,eval([var{1} '= [];']);end

% Loop through subjects to extract and balance fast/slow groups
for sub = 1:nsubj
    subj = all_subjects(sub); % Current subject
    ind_sub = find(fast_slow_subs == subj);
    subject_data = fast_slow_data(ind_sub);

    % Define subject-specific paths and file names
    eeg_file_dir = sprintf('C:\\Users\\SARA\\Documents\\MATLAB_files\\data\\Motor\\EEG_files_new\\s%02d\\', subj);
    ersp_file_name = sprintf('emg_singletrl_s%d.mat', subj);
    cd(eeg_file_dir);

    % Load ERSP data and calculate power
    ersp_data = load(ersp_file_name);
    current_ersp = squeeze(mean(abs(ersp_data.tfdata), 1)); % Mean across frequency bands
    time_vec = ersp_data.times;

    % Randomly sample trials to ensure balanced data for fast and slow subjects
    if strcmp(subject_data.subjectSpeed, 'fast')
        rand_trls = sort(randperm(size(current_ersp, 2), min_substrl_len));
        fast_subs = [fast_subs, current_ersp(:, rand_trls)];
        fast_subs_emgonest = [fast_subs_emgonest, subject_data.emg_onsets(rand_trls)];
    elseif strcmp(subject_data.subjectSpeed, 'slow')
        rand_trls = sort(randperm(size(current_ersp, 2), min_substrl_len));
        slow_subs = [slow_subs, current_ersp(:, rand_trls)];
        slow_subs_emgonest = [slow_subs_emgonest, subject_data.emg_onsets(rand_trls)];
    end

    % Select random trials for fast and slow trials
    fast_trials = subject_data.fastTrls(sort(randperm(length(subject_data.fastTrls), min_trlstrl_len)));
    slow_trials = subject_data.slowTrls(sort(randperm(length(subject_data.slowTrls), min_trlstrl_len)));

    fast_trls = [fast_trls, current_ersp(:, fast_trials)];
    fast_trls_emgonsets = [fast_trls_emgonsets, subject_data.emg_onsets(fast_trials)];
    slow_trls = [slow_trls, current_ersp(:, slow_trials)];
    slow_trls_emgonsets = [slow_trls_emgonsets, subject_data.emg_onsets(slow_trials)];
end

% Organize results into a structured format
fs_groups_EMG_ersp = struct('fastSubs', fast_subs, 'slowSubs', slow_subs, ...
    'fastSubsEMGonset', fast_subs_emgonest, 'slowSubsEMGonset', slow_subs_emgonest, ...
    'fastTrls', fast_trls, 'slowTrls', slow_trls, ...
    'fastTrlsEMGonset', fast_trls_emgonsets, 'slowTrlsEMGonset', slow_trls_emgonsets);

% Save the results
cd(file_path);
save('EMG_ersp_fast_slow_subtrl_balanced_groups.mat', "fs_groups_EMG_ersp", 'time_vec');
