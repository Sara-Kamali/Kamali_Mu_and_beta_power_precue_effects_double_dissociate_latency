% Perform cluster-based permutation t-test on two input groups.
% Returns p-values for clusters and the indices of significant clusters.

function [p_values, idx] = permutation_test_on_clusters(group1, group2, n_permutations, p_value_data, p_value_cluster)

    % Perform t-test between groups
    [~, p_values, ~, stats_ttest] = ttest2(group1, group2, 'dim', 2, 'Vartype', 'unequal');
    t_values = stats_ttest.tstat;

    % Find significant time points based on the p-value threshold
    significant_time_points = p_values < p_value_data;
    clusters = bwconncomp(significant_time_points); % Identify clusters of significant points

    % Calculate cluster-level statistics (sum of t-values within clusters)
    if clusters.NumObjects > 0
        cluster_stat = cellfun(@(x) sum(abs(t_values(x))), clusters.PixelIdxList);
    else
        cluster_stat = [];
    end

    % Prepare for permutation testing
    max_cluster_stats = zeros(1, n_permutations);
    all_data = [group1, group2];
    [~, T1] = size(group1);
    [~, T2] = size(group2);
    total_trials = T1 + T2;

    % Run permutation test
    for i = 1:n_permutations
        % Randomly shuffle the data labels
        permuted_labels = randperm(total_trials);
        permuted_group1 = all_data(:, permuted_labels(1:T1));
        permuted_group2 = all_data(:, permuted_labels(T1 + 1:end));

        % Compute t-test on permuted data
        [~, perm_p_values, ~, perm_stats] = ttest2(permuted_group1, permuted_group2, 'Dim', 2, 'Vartype', 'unequal');
        perm_t_values = perm_stats.tstat;

        % Identify clusters in permuted data
        significant_perm_time_points = perm_p_values < p_value_data;
        perm_clusters = bwconncomp(significant_perm_time_points);

        % Calculate the max cluster statistic for the permuted clusters
        if perm_clusters.NumObjects > 0
            perm_cluster_stat = cellfun(@(x) sum(abs(perm_t_values(x))), perm_clusters.PixelIdxList);
            max_cluster_stats(i) = max(perm_cluster_stat);
        else
            max_cluster_stats(i) = 0;
        end
    end

    % Determine the significance of observed clusters
    if ~isempty(cluster_stat)
        p_values_clusters = arrayfun(@(x) mean(max_cluster_stats >= x), cluster_stat);
    else
        p_values_clusters = [];
    end

    % Identify significant clusters based on p-value threshold
    significant_clusters = find(p_values_clusters < p_value_cluster);

    % Prepare output with indices of significant clusters
    idx = cell(1, length(significant_clusters));
    if ~isempty(significant_clusters)
        for i = 1:length(significant_clusters)
            idx{i} = clusters.PixelIdxList{significant_clusters(i)};
        end
    end

    % Display results
    disp(['Number of significant clusters: ', num2str(length(significant_clusters))]);

end
