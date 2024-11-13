% This code generates a study file for motor data analysis based on previously processed and cleaned EEG data, 
% for subjects with good recording quality. It only keeps the brain and eye components and removes the rest from the analysis.
clc; clear all;

% Set paths for EEGLAB, codes, and subject data directories
base_path = 'path to main folder';
eeglab_path = 'path to EEGlab';
code_path = 'path to matlab codes';
data_path ='path to EEG data';
study_path = 'path to save STUDY';

% Initialize EEGLAB and add required paths
addpath(eeglab_path); eeglab; close;
addpath(code_path);
addpath(data_path);
addpath(study_path);

% List of subjects with good data for motor or sensory analysis
subjects = [3, 4, 5, 9, 13, 14, 19, 22, 23, 25, 27, 30, 35, 36, 46, 48, 49, 50, 52];
nsubj = length(subjects);  % Number of subjects

% Preallocate cell array to store good components for each subject
components = cell(1, nsubj);

% Initialize ALLEEG structure
ALLEEG = struct();

% Helper function to generate the EEG file path
generate_eeg_file_path = @(subj) fullfile(data_path, sprintf('s%02d', subj));

% Loop over subjects to load data and extract good components
for current_subj = 1:nsubj
    subj = subjects(current_subj);
    eeg_file_out_dir = generate_eeg_file_path(subj);
    cd(eeg_file_out_dir);  % Change directory to the current subject's file directory
    
    % Load the processed EEG data file
    EEG_file_name = sprintf('processed_merged_RL%d.set', subj);
    EEG = pop_loadset('filename', EEG_file_name, 'filepath', eeg_file_out_dir);
    
    % Store good components for clustering
    components{current_subj} = EEG.components_to_cluster.good_comps;
    
    % Store EEG data in ALLEEG structure
    [ALLEEG, ~, ~] = eeg_store(ALLEEG, EEG, current_subj);
end

% Create and configure the STUDY structure
STUDY = struct();
[STUDY, ALLEEG] = std_editset(STUDY, ALLEEG, 'name', 'goodSubjects', 'updatedat', 'on', ...
    'task', 'Hand_movement', 'filename', 'finger_pinching_study.study', 'filepath', study_path);

% Add only good components to the STUDY structure
for sub = 1:nsubj
    [STUDY, ALLEEG] = std_editset(STUDY, ALLEEG, 'commands', ...
        {{'index' sub 'comps' components{sub}}}, 'filename', 'finger_pinching_study.study', ...
        'filepath', study_path);
end

