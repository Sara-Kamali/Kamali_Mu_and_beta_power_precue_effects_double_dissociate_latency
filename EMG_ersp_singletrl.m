% This code performs single trial time-frequency decomposition on bipolar EMG signals
% within the 20 to 256 Hz range for selected subjects.

% Set paths for data and code dependencies
files_path = 'path to data';
cd(files_path);

% Add EEGLAB and other required paths
eeglab_path = 'path to EEGlab';
addpath(eeglab_path); eeglab; close;

% Define subjects and study parameters
subjects = [3, 4, 5, 9, 13, 14, 19, 22, 23, 25, 27, 30, 35, 36, 46, 48, 49, 50, 52];
nsubj = length(subjects);
sampling_rate = 512; % Sampling rate in Hz
frequencies = {20:1:200, 201:1:sampling_rate/2 - 1}; % Frequency ranges for ERSP
timesout = 0.25:1/sampling_rate:(7 - 1/sampling_rate) - 0.25; % Time vector
significance = 0.05; % Significance level for ERSP

% Loop over subjects to calculate ERSP on bipolar EMG
for current_subj = 1:nsubj
    subj = subjects(current_subj);
    
    % Set file names for current subject's EMG and EEG data
    ersp_file_name = {
        sprintf('emg_singletrl_s%02d.mat', subj), ...
        sprintf('emg_singletrl_s%02d_high.mat', subj)
    };
    
    % Define subject-specific directory and move to it
    eeg_file_dir = fullfile('C:\Users\SARA\Documents\MATLAB_files\data\Motor\EEG_files_new', sprintf('s%02d', subj));
    cd(eeg_file_dir);
    
    % Load EMG data results and EEG data set
    emg_file_name = sprintf('EMG_analysis_results_s%d.mat', subj);
    load(emg_file_name);
    
    eeg_file_name = sprintf('processed_merged_RL%d.set', subj);
    EMG = pop_loadset('filename', eeg_file_name, 'filepath', eeg_file_dir);
    
    % Add bipolar EMG data as a new channel in the EEG structure for ICA decomposition
    emg_chan = size(EMG.chanlocs, 2) + 1; % New channel index
    EMG.data(emg_chan, :, :) = bipolar_emg;
    
    % Perform time-frequency decomposition for each frequency range
    for frange = 1:2
        [ersp, itc, powbase, times, freqs, erspboot, itcboot, tfdata] = pop_newtimef(EMG, 1, emg_chan, ...
            [EMG.xmin EMG.xmax] * 1000, [3 0.5], 'freqs', frequencies{frange}, ...
            'plotphase', 'off', 'timesout', 1000 * timesout, 'padratio', 2, ...
            'alpha', significance, 'plotersp', 'off', 'plotitc', 'off');
        
        % Save time-frequency data in the subject's folder
        if frange == 1
            save(ersp_file_name{frange}, "tfdata", "times", 'freqs');
        else
            tfdata_high = tfdata;
            save(ersp_file_name{frange}, "tfdata_high", "times", 'freqs');
        end
    end
end
