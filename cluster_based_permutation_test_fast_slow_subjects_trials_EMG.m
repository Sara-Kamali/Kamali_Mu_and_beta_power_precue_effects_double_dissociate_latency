% Compare the EMG time-frequency of single trials for the fast and slow subjects and trials to 
% get the significance difference between two groups. This is for EMG data time locked to the go cue.
% We are using the t-test and FDR on the subset of the original dataset, with equalized trials per subject.

clearvars; clc;

% Set default plot values
set(groot, 'DefaultAxesFontSize', 14, 'DefaultLineLineWidth', 2, 'DefaultTextFontSize', 14);

% Load data
load('MS_cls_info.mat'); 
load('EMG_ersp_fast_slow_subtrl_balanced_groups.mat');
load('fast_slow_subject_ind.mat'); 
load('fast_slow_subtrl_data.mat');

% Add code and data paths
files_path = 'data path';
addpath(files_path);

% Set parameters
t_cue = 2000; t_end = 5000; time_vec=times;
data_type = {'subjects', 'trials'};
colors_sig_tval = [.5, .85, .85; 0.2, .45, .45];
colors_fdr = [1, .9, .1; .85, .5, .2];
facealpha = [.1, .15];
num_perms = 10; 
p_value_data = 0.05; 
p_value_cluster = [0.05, 0.01];

% Initialize results storage
variables = {'p_values','IDX', 'ind_fdr'};
for v = 1:length(variables)
    eval([variables{v} ' = cell(length(p_value_cluster), length(data_type));']);
end

% Plot setup
h1 = figure; h1.WindowState = 'maximized';

% Loop over subjects and trials to perform tests and plot
for mod = 1:2
    % Select data for fast/slow groups (1: subjects, 2: trials)
    if mod == 1
        fast_data = squeeze(fs_groups_EMG_ersp.fastSubs);
        slow_data = squeeze(fs_groups_EMG_ersp.slowSubs);
    else
        fast_data = squeeze(fs_groups_EMG_ersp.fastTrls);
        slow_data = squeeze(fs_groups_EMG_ersp.slowTrls);
    end

    % Perform permutation test and FDR correction
    for p = 1:2
        fprintf('Performing cluster-based permutation on fast vs slow %s with p-value=%s\n', data_type{mod}, num2str(p_value_cluster(p)));
        [p_values{p, mod}, IDX{p, mod}] = permutation_test_on_clusters(fast_data, slow_data, num_perms, p_value_data, p_value_cluster(p));

        % FDR correction
        [~, ~, ~, adj_p] = fdr_bh(p_values{p, mod}');
        ind_fdr{p, mod} = find(adj_p < p_value_cluster(p));
    end

    % Plot results
    subplot(3, 2, mod);
    iqr_seq_fast = iqr(fast_data, 2);
    iqr_seq_slow = iqr(slow_data, 2);
    y11 = mean(fast_data, 2) - iqr_seq_fast / 2; 
    y12 = mean(fast_data, 2) + iqr_seq_fast / 2;
    y21 = mean(slow_data, 2) - iqr_seq_slow / 2; 
    y22 = mean(slow_data, 2) + iqr_seq_slow / 2;
    
    plot(time_vec, mean(fast_data, 2), 'r', 'LineWidth', 1.2); hold on;
    plot(time_vec, mean(slow_data, 2), 'b', 'LineWidth', 1.2); hold on;
    shade(time_vec, y11', y12', 'r');  % Shade IQR of fast data
    shade(time_vec, y21', y22', 'b');  % Shade IQR of slow data
    xline(t_cue, '--k', 'LineWidth', 1); hold on;
    xline(t_end, '--k', 'LineWidth', 1); hold on;

    % Calculate rug plot position
    y_lim = ylim; 
    y_range = y_lim(2) - y_lim(1);
    curve_min = min([min(mean(fast_data, 2)), min(mean(slow_data, 2))]);
    rug_pos = curve_min - 0.05 * y_range;
    
    for p = 1:2
        yline(rug_pos, 'k', 'LineWidth', 0.7);

        % Highlight significant clusters for permutation test
        if ~isempty(p_values{p, mod})
            idx = IDX{p, mod};
            for i = 1:length(idx)
                xvec = time_vec(idx{i});
                x_patch = [xvec(1), xvec(end), xvec(end), xvec(1)];
                y_patch = [rug_pos, rug_pos, y_lim(2), y_lim(2)];
                patch(x_patch, y_patch, colors_sig_tval(p, :), 'FaceAlpha', facealpha(p), 'EdgeColor', 'none'); hold on;
                plot(xvec, ones(1, length(xvec)) * (rug_pos - 0.025 * y_range), 'Color', colors_sig_tval(p, :), 'LineWidth', 8); hold on;
            end
        end

        % Highlight FDR-corrected p-values
        if ~isempty(ind_fdr{p, mod})
            FDR_sig_pval = NaN(1, length(time_vec));
            FDR_sig_pval(ind_fdr{p, mod}) = rug_pos - 0.075 * y_range;
            plot(time_vec, FDR_sig_pval, 'Color', colors_fdr(p, :), 'LineWidth', 6); hold on;
        end
    end

    ylim([rug_pos - 0.1 * y_range, y_lim(2)]);
    xlim('tight');
    title(sprintf('Fast vs Slow %s', data_type{mod}));
    xlabel('Time (ms)');
    if mod == 1, ylabel('EMG 20-200 Hz Power (\muV^2)'); end
    set(gca, 'FontWeight', 'bold', 'FontSize', 14);
end

% Set main title
sgtitle(sprintf('Fast and Slow EMG Comparison, #perm=%s, pval_{data}=0.05, pval_{cluster}=0.01 or 0.05', num2str(num_perms)), 'FontSize', 20);

% Save figure as high-resolution PNG
print('EMG_perm.png', '-dpng', '-r500');
