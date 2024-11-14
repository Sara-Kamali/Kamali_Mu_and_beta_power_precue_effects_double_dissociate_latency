% This script compares fast and slow data, for trait and state-based approaches. Data is the 
% mu and beta band powers, time-locked to the go cue. We used cluster-based permutation with 
% Welch's t-test and FDR-correction on a balanced subset of the original dataset to ensure 
% all the subjects contributed an equal number of trials to the analysis.

clearvars; clc;

%% Set default plot properties
set(groot, 'DefaultAxesFontSize', 14, 'DefaultLineLineWidth', 2, 'DefaultTextFontSize', 14);

% Load data
load('MS_cls_info.mat');
load('EEG_ersp_fast_slow_subtrl_balanced_per_cls.mat');
load('fast_slow_subject_ind.mat');
load('fast_slow_subtrl_data.mat');

% Define paths and add required directories
files_path = 'data path';
addpath(files_path);
addpath('codes path');

% Cluster and parameter info
main_cls = [3, 5, 1, 2, 4];
num_cls = length(main_cls);
clusters_name = {'RVA', 'LSM', 'VA', 'RSM', 'LVA'};
band_names = {'mu', 'beta'};
t_cue = 2000; t_end = 5000;
data_type = {'subjects', 'trials'};
time_vec=times;

% Colors and plot settings
colors_sig_tval = [.5, .85, .85; 0.2, .45, .45];
colors_fdr = [1, .9, .1; .85, .5, .2];
facealpha = [.1, .15];
num_perms = 1000; p_value_data = .05; p_value_cluster = [.05, .01];

% Initialize matrices to save results
variables = {'p_values', 'IDX', 'ind_fdr', 'adj_p_fdr'};
for v = variables
    eval([v{1} ' = cell(num_cls, length(p_value_cluster), length(data_type), length(band_names));']);
end

%% Loop over mu and beta bands and conditions (trait and state-based)
% to perform significance testing for each cluster
for band = 1:2
    for mod = 1:2 % for trait (fast/slow subject) and state (fast/slow trials) groups
        h1 = figure; h1.WindowState = 'maximized';
        for cls = 1:num_cls
            % Retrieve fast and slow power
            if mod == 1
                fast_data = squeeze(fs_groups_ersp(main_cls(cls)).fastSubs(band, :, :));
                slow_data = squeeze(fs_groups_ersp(main_cls(cls)).slowSubs(band, :, :));
            else
                fast_data = squeeze(fs_groups_ersp(main_cls(cls)).fastTrls(band, :, :));
                slow_data = squeeze(fs_groups_ersp(main_cls(cls)).slowTrls(band, :, :));
            end

            for p = 1:2 % Testing over two p-value thresholds
                % Permutation testing on clusters
                [p_values{cls, p, mod, band}, IDX{cls, p, mod, band}] = ...
                    permutation_test_on_clusters(fast_data, slow_data, num_perms, p_value_data, p_value_cluster(p));

                % FDR correction
                [~, ~, ~, adj_p] = fdr_bh(p_values{cls, p, mod, band}');
                ind_fdr{cls, p, mod, band} = find(adj_p < p_value_cluster(p));
            end

            % Compute mean and IQR for fast and slow groups
            iqr_fast = iqr(fast_data, 2);
            iqr_slow = iqr(slow_data, 2);
            y11 = mean(fast_data, 2) - iqr_fast / 2; y12 = mean(fast_data, 2) + iqr_fast / 2;
            y21 = mean(slow_data, 2) - iqr_slow / 2; y22 = mean(slow_data, 2) + iqr_slow / 2;

            %%Plot results
            subplot(3,2,cls)
            hold on;

            % Plot mean and IQR shaded regions
            plot(time_vec, mean(fast_data, 2), 'r', 'LineWidth', 1.5);
            plot(time_vec, mean(slow_data, 2), 'b', 'LineWidth', 1.5);
            shade(time_vec, y11', y12', 'r');
            shade(time_vec, y21', y22', 'b');
            xline(t_cue, '--', 'color', 'k', 'linewidth', 1.5);
            xline(t_end, '--', 'color', 'k', 'linewidth', 1.5);

            % Define y-axis limits for the rug plot
            y_lim = ylim;
            y_range = y_lim(2) - y_lim(1);

            % Define the distance between the two lines for rug plot
            dist_rugs = 0.1 * y_range;

            % Initialize variable for the minimum curve value
            curve_min = Inf;

            % Loop through each child object in the current axis
            children = get(gca, 'Children');
            for i = 1:length(children)
                % Check if the object has 'YData' property
                if isprop(children(i), 'YData')
                    y_data = get(children(i), 'YData');
                    curve_min = min(curve_min, min(y_data));
                end
            end

            % Move the horizontal line slightly below the minimum curve value
            first_rug_pos = curve_min - 0.05 * y_range;

            for p = 1:2
                rug_pos=first_rug_pos;
                yline(rug_pos, 'k', 'LineWidth', .7);

                % Plot significant clusters based on permutation and FDR tests
                if ~isempty(p_values{cls, p, mod, band})
                    for i = 1:length(IDX{cls, p, mod, band})
                        xvec = time_vec(IDX{cls, p, mod, band}{i});
                        yvec=ones(1,length(xvec))*(rug_pos-y_range*0.025);
                        x_patch = [xvec(1) xvec(2) xvec(2) xvec(1)];
                        y_patch = [rug_pos rug_pos y_lim(2) y_lim(2)];
                        patch(x_patch, y_patch, colors_sig_tval(p,:), 'FaceAlpha', facealpha(p),...
                            'EdgeColor', 'none');hold on
                        plot(xvec,yvec,'color',colors_sig_tval(p,:),'linewidth',8);hold on
                    end
                end

                if ~isempty(ind_fdr{cls, p, mod, band})
                    fdr_sig = NaN(1, length(time_vec));
                    fdr_sig(ind_fdr{cls, p, mod, band}) = rug_pos - y_range * .075;
                    plot(time_vec, fdr_sig, 'color', colors_fdr(p, :), 'linewidth', 6);
                end
            end

            shade(time_vec, y11', y12', 'r');
            shade(time_vec, y21', y22', 'b');

            ylim([first_rug_pos - dist_rugs, y_lim(2)]);
            xlim('tight');
            ylabel(sprintf('%s Mu power \\muV^2', clusters_name{main_cls(cls)}));
            if cls > 3, xlabel('Time (ms)'); else, xticklabels(''); end
            set(gca, 'FontWeight', 'bold', 'fontsize', 14);
        end

        % Set title and save the figure
        sgtitle(sprintf(['Fast and slow %s, %s power, #perm=%d, p_{data}=.05, ' ...
            'p_{cluster}=[.01,.05]'], data_type{mod}, band_names{band}, num_perms), 'fontsize', 20);
        resolution = 500;
        cd('path to save plots');
        print(sprintf('%s_%s_band.png', data_type{mod}, band_names{band}), '-dpng', ['-r', num2str(resolution)]);
    end
end

