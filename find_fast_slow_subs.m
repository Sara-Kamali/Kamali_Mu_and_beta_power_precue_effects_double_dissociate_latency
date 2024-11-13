% This code identifies fast and slow EMG trials and subjects based on EMG onset times.
clear all; clc;

%% Set default plot values
set(groot, 'DefaultAxesFontSize', 14, 'DefaultLineLineWidth', 2, 'DefaultTextFontSize', 14);

% Define paths for files and data
files_path = 'path to data';
addpath(files_path);

% Define study parameters and frequency bands
subjects = [3, 4, 5, 9, 13, 14, 19, 22, 23, 25, 27, 30, 35, 36, 46, 48, 49, 50, 52];
nsubj = length(subjects);
frq_bands = {7:14, 15:28, 30:40, 7:40}; % Frequency ranges
band_names = {'mu', 'beta', 'gamma', '7 to 40 Hz'};
clusters_name = {'Right VA', 'Left MotorSensory', 'Visual', 'Right MotorSensory', 'Left VA'};
num_frq = length(frq_bands);

% Thresholds for categorizing trials and subjects
p30 = 30; p70 = 70; % Percentile thresholds

%% Calculate average EMG onset and categorize trials for each subject
fast_slow_data = [];
emg_stat_all_subs = zeros(1, nsubj);

for sub = 1:nsubj
    subj = subjects(sub);
    
    % Define subject-specific EEG file directory
    eeg_file_dir = fullfile(files_path, sprintf('s%02d', subj));
    cd(eeg_file_dir);
    
    % Load EMG analysis results
    emg_file = sprintf("EMG_analysis_results_s%d.mat", subj);
    load(emg_file);
    
    % Calculate mean EMG onset for current subject
    emg_stat_all_subs(sub) = mean(emg_onset);
    
    % Identify fast and slow trials based on percentiles
    fast_trls = find(emg_onset <= prctile(emg_onset, p30));
    slow_trls = find(emg_onset >= prctile(emg_onset, p70));
    
    % Structure to hold trial data for each subject
    fast_slow_data = [fast_slow_data, struct( ...
        'subject', subj, ...
        'emgmean', emg_stat_all_subs(sub), ...
        'fastTrls', fast_trls, ...
        'meanFastTrls', mean(emg_onset(fast_trls)), ...
        'slowTrls', slow_trls, ...
        'meanSlowTrls', mean(emg_onset(slow_trls)), ...
        'emg_onsets', emg_onset, ...
        'hand_change_trl', Hand_change_trial_ind)]; %#ok<*AGROW>
end


%% Identify fast and slow subjects based on EMG onset means
fast_subs_ind = find(emg_stat_all_subs <= prctile(emg_stat_all_subs, p30));
slow_subs_ind = find(emg_stat_all_subs >= prctile(emg_stat_all_subs, p70));

fast_subs = subjects(fast_subs_ind);
slow_subs = subjects(slow_subs_ind);

for sub = 1:nsubj
    subj = subjects(sub);
    if ismember(subj, fast_subs)
        subtype = 'fast';
    elseif ismember(subj, slow_subs)
        subtype = 'slow';
    else
        subtype = 'norm';
    end
    fast_slow_data(sub).subjectSpeed = subtype;
end

% Save categorized subjects
fast_slow_subjects_num = struct('FastSubs', fast_subs, 'SlowSubs', slow_subs);
save('fast_slow_subtrl_data.mat', 'fast_slow_data');
save('fast_slow_subject_ind.mat', 'fast_slow_subjects_num');

%% Plot mean EMG onset categorized by speed
emg_mean = emg_stat_all_subs-2;
upper_threshold = prctile(emg_mean, p70);
lower_threshold = prctile(emg_mean, p30);

fast_subjects = emg_mean < lower_threshold;
slow_subjects = emg_mean > upper_threshold;
rest_subjects = (emg_mean >= lower_threshold) & (emg_mean <= upper_threshold);

figure;
hold on;
scatter(find(fast_subjects), emg_mean(fast_subjects), 'filled', 'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'k', 'SizeData', 140, 'DisplayName', 'Fast Subjects (< 30%)');
scatter(find(slow_subjects), emg_mean(slow_subjects), 'filled', 'MarkerFaceColor', 'b', ...
    'MarkerEdgeColor', 'k', 'SizeData', 140, 'DisplayName', 'Slow Subjects (> 70%)');
scatter(find(rest_subjects), emg_mean(rest_subjects), 'filled', 'MarkerFaceColor', 'g', ...
    'MarkerEdgeColor', 'k', 'SizeData', 140, 'DisplayName', 'Rest of the Subjects (30%-70%)');
yline(upper_threshold, '--b', 'LineWidth', 2);
yline(lower_threshold, '--r', 'LineWidth', 2);

% Customize plot appearance
xlabel('Subject Index', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('Mean EMG Onset (ms)', 'FontSize', 18, 'FontWeight', 'bold');
title('Mean EMG Onset Categorized by Speed', 'FontSize', 18, 'FontWeight', 'bold');
set(gca, 'fontsize', 18, 'fontweight', 'bold', 'XTick', 1:nsubj, 'XTickLabel', subjects);
legend('show', 'FontSize', 18, 'fontweight', 'bold');
hold off;
