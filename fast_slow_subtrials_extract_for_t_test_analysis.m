% This code creates a balanced pool of single trials power for the fast and slow subjects 
% and trials for t-tests.
clc; clear;

% Set default plot properties
set(groot, 'DefaultAxesFontSize', 14, 'DefaultLineLineWidth', 2, 'DefaultTextFontSize', 14);
% Define paths
file_path = 'data path';
addpath(file_path);

% Load required data
load('fast_slow_subject_ind.mat'); % Fast and slow subject/trial data
load('fast_slow_subtrl_data.mat'); % Cluster information
load("MS_cls_info.mat");

% Set study parameters
fast_slow_subs = [fast_slow_data.subject];
clusters = [3, 4, 7, 9, 10];
num_cls = length(clusters);
frq_bands = {7:14, 15:28, 30:40, 7:40}; % Frequency ranges

% Initialize minimum trial count to balance trial selection for both trait and state-based
% analysis
min_trial_counts = struct('min_fast_substrl_len', ones(1, num_cls) * 40, ...
                          'min_slow_substrl_len', ones(1, num_cls) * 40, ...
                          'min_fast_trlstrl_len', ones(1, num_cls) * 40, ...
                          'min_slow_trlstrl_len', ones(1, num_cls) * 40);

%% Determine minimum number of trials per subject for fast/slow groups
for cls = 1:num_cls
    subs = subjects{cls}; % Subjects in the current cluster
    for sub_idx = 1:length(subs)
        subj = subs(sub_idx);
        ind_sub = find(fast_slow_subs == subj);
        
        % Update min trial counts based on subject speed classification
        if strcmp(fast_slow_data(ind_sub).subjectSpeed, 'fast')
            min_trial_counts.min_fast_substrl_len(cls) = min(min_trial_counts.min_fast_substrl_len(cls), length(fast_slow_data(ind_sub).emg_onsets));
        elseif strcmp(fast_slow_data(ind_sub).subjectSpeed, 'slow')
            min_trial_counts.min_slow_substrl_len(cls) = min(min_trial_counts.min_slow_substrl_len(cls), length(fast_slow_data(ind_sub).emg_onsets));
        end
        min_trial_counts.min_fast_trlstrl_len(cls) = min(min_trial_counts.min_fast_trlstrl_len(cls), length(fast_slow_data(ind_sub).fastTrls));
        min_trial_counts.min_slow_trlstrl_len(cls) = min(min_trial_counts.min_slow_trlstrl_len(cls), length(fast_slow_data(ind_sub).slowTrls));
    end
end

%% Initialize storage for balanced fast and slow trial data
trial_data = {'fast_subs_cls', 'slow_subs_cls', 'fast_trls_cls', 'slow_trls_cls', ...
              'fast_trls_cls_emgonsets', 'slow_trls_cls_emgonsets', ...
              'fast_subs_cls_emgonest', 'slow_subs_cls_emgonest', ...
              'fast_sub_subindx', 'slow_sub_subindx', 'fast_trl_subindx', 'slow_trl_subindx'};
for v = trial_data
    eval([v{1} ' = cell(1, num_cls);']);
end

%% Loop through clusters and subjects to gather ERSP data for fast/slow groups
for cls = 1:num_cls
    subs = subjects{cls};
    comps = components{cls};
    for sub_idx = 1:length(subs)
        subj = subs(sub_idx);
        comp = comps(sub_idx);
        ind_sub = find(fast_slow_subs == subj);
        
        % Set the subject-specific directory and file name
        eeg_file_dir = fullfile(file_path, sprintf('s%02d', subj));
        ersp_file_name = sprintf('s%02d.mat.icatimef', subj);
        
        % Load ERSP, time and frequency vectors data for the current component
        cd(eeg_file_dir);
        ersp_data = load(ersp_file_name, '-mat');
        frequencies = ersp_data.freqs;
        time_vec = ersp_data.times;
        
        % Calculate power from complex ERSP data
        ersp_current_cmplx = eval(sprintf('ersp_data.comp%s', num2str(comp)));
        current_ersp = abs(ersp_current_cmplx).^2;
        
        % Limit ERSP to specified frequency bands
        band_limited_ersp = zeros(length(frq_bands), size(current_ersp, 2), size(current_ersp, 3));
        for freq_band = 1:length(frq_bands)
            band_limited_ersp(freq_band, :, :) = mean(current_ersp(2 * frq_bands{freq_band} - 13, :, :), 1);
        end
        current_ersp = band_limited_ersp;

        % Extract trials randomely in the required size for fast/slow subjects
        if strcmp(fast_slow_data(ind_sub).subjectSpeed, 'fast')
            rand_trls = sort(randperm(size(current_ersp, 3), min_trial_counts.min_fast_substrl_len(cls)));
            fast_subs_cls{cls} = cat(3, fast_subs_cls{cls}, current_ersp(:, :, rand_trls));
            fast_subs_cls_emgonest{cls} = cat(2, fast_subs_cls_emgonest{cls}, fast_slow_data(ind_sub).emg_onsets(rand_trls));
            fast_sub_subindx{cls} = cat(1, fast_sub_subindx{cls}, repmat(subj, min_trial_counts.min_fast_substrl_len(cls), 1));
        elseif strcmp(fast_slow_data(ind_sub).subjectSpeed, 'slow')
            rand_trls = sort(randperm(size(current_ersp, 3), min_trial_counts.min_slow_substrl_len(cls)));
            slow_subs_cls{cls} = cat(3, slow_subs_cls{cls}, current_ersp(:, :, rand_trls));
            slow_subs_cls_emgonest{cls} = cat(2, slow_subs_cls_emgonest{cls}, fast_slow_data(ind_sub).emg_onsets(rand_trls));
            slow_sub_subindx{cls} = cat(1, slow_sub_subindx{cls}, repmat(subj, min_trial_counts.min_slow_substrl_len(cls), 1));
        end

        % Randomely extract balanced fast/slow trials
        ftrl = fast_slow_data(ind_sub).fastTrls;
        f_randtrl = sort(randperm(length(ftrl), min_trial_counts.min_fast_trlstrl_len(cls)));
        ftrl = ftrl(f_randtrl);
        strl = fast_slow_data(ind_sub).slowTrls;
        s_randtrl = sort(randperm(length(strl), min_trial_counts.min_slow_trlstrl_len(cls)));
        strl = strl(s_randtrl);

        fast_trls_cls{cls} = cat(3, fast_trls_cls{cls}, current_ersp(:, :, ftrl));
        fast_trls_cls_emgonsets{cls} = cat(2, fast_trls_cls_emgonsets{cls}, fast_slow_data(ind_sub).emg_onsets(ftrl));
        slow_trls_cls{cls} = cat(3, slow_trls_cls{cls}, current_ersp(:, :, strl));
        slow_trls_cls_emgonsets{cls} = cat(2, slow_trls_cls_emgonsets{cls}, fast_slow_data(ind_sub).emg_onsets(strl));
        fast_trl_subindx{cls} = cat(1, fast_trl_subindx{cls}, repmat(subj, min_trial_counts.min_fast_trlstrl_len(cls), 1));
        slow_trl_subindx{cls} = cat(1, slow_trl_subindx{cls}, repmat(subj, min_trial_counts.min_slow_trlstrl_len(cls), 1));
    end
end

% Compile results into a structured variable for saving
fs_groups_ersp = struct('fastSubs', fast_subs_cls, 'slowSubs', slow_subs_cls, ...
                        'fastSubsEMGonset', fast_subs_cls_emgonest, 'slowSubsEMGonset', slow_subs_cls_emgonest, ...
                        'fastTrls', fast_trls_cls, 'slowTrls', slow_trls_cls, ...
                        'fastTrlsEMGonset', fast_trls_cls_emgonsets, 'slowTrlsEMGonset', slow_trls_cls_emgonsets, ...
                        'fastSubInd', fast_sub_subindx, 'slowSubInd', slow_sub_subindx, ...
                        'fastTrlInd', fast_trl_subindx, 'slowTrlInd', slow_trl_subindx);

% Save the results
cd(file_path);
save('EEG_ersp_fast_slow_subtrl_balanced_per_cls.mat', "fs_groups_ersp", 'time_vec', 'frequencies');
