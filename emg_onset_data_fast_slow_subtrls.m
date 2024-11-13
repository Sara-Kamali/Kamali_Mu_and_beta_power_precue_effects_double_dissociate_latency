% This code extracts min, max, coefficient of variation (CV), and mean for EMG latencies of fast and slow subjects and trials
% for trait and state-based analysis, and generates a violin plot.

clc; clear;

% Set default plot properties
set(groot, 'DefaultAxesFontSize', 14, 'DefaultLineLineWidth', 2, 'DefaultTextFontSize', 14);

% Define paths and add required directories
file_path = 'data path';
addpath(file_path);

% Load initial data
load('fast_slow_subject_ind.mat'); % Fast and slow subject/trial data
load('fast_slow_subtrl_data.mat'); % Cluster information
load("MS_cls_info.mat");

% Initialize storage for EMG onset times
fast_subs_emgt = []; slow_subs_emgt = []; fast_trls_emgt = []; slow_trls_emgt = [];

% Extract EMG onset times for fast and slow subjects and trials
for sub = 1:length(fast_slow_data)
    subj = fast_slow_data(sub).subject;
    emg_onsets = fast_slow_data(sub).emg_onsets - 2;
    
    % Separate EMG data by subject speed category
    if strcmp(fast_slow_data(sub).subjectSpeed, 'fast')
        fast_subs_emgt = [fast_subs_emgt, emg_onsets];
    elseif strcmp(fast_slow_data(sub).subjectSpeed, 'slow')
        slow_subs_emgt = [slow_subs_emgt, emg_onsets];
    end
    
    % Extract fast and slow trial's EMG onset times
    fast_trls_emgt = [fast_trls_emgt, emg_onsets(fast_slow_data(sub).fastTrls)];
    slow_trls_emgt = [slow_trls_emgt, emg_onsets(fast_slow_data(sub).slowTrls)];
end

% Compute statistics for fast and slow subjects and trials
fast_subs_data = [min(fast_subs_emgt), max(fast_subs_emgt), std(fast_subs_emgt) / mean(fast_subs_emgt) , mean(fast_subs_emgt)];
slow_subs_data = [min(slow_subs_emgt), max(slow_subs_emgt), std(slow_subs_emgt) / mean(slow_subs_emgt) , mean(slow_subs_emgt)];
fast_trls_data = [min(fast_trls_emgt), max(fast_trls_emgt), std(fast_trls_emgt) / mean(fast_trls_emgt) , mean(fast_trls_emgt)];
slow_trls_data = [min(slow_trls_emgt), max(slow_trls_emgt), std(slow_trls_emgt) / mean(slow_trls_emgt) , mean(slow_trls_emgt)];

emg_data = struct('fastSubsEMGonset', fast_subs_data, 'slowSubsEMGonset', slow_subs_data, ...
                  'fastTrlsEMGonset', fast_trls_data, 'slowTrlsEMGonset', slow_trls_data);

% Prepare data for the violin plot
max_len = max([length(fast_subs_emgt), length(slow_subs_emgt), length(fast_trls_emgt), length(slow_trls_emgt)]);
data_matrix = [padarray(fast_subs_emgt(:), max_len - length(fast_subs_emgt), NaN, 'post'), ...
               padarray(slow_subs_emgt(:), max_len - length(slow_subs_emgt), NaN, 'post'), ...
               padarray(fast_trls_emgt(:), max_len - length(fast_trls_emgt), NaN, 'post'), ...
               padarray(slow_trls_emgt(:), max_len - length(slow_trls_emgt), NaN, 'post')];

% Define colors for each category in the plot
color_mat(1,:)=[1,0,0];% red
color_mat(2,:)=[0.2,0.2,1]; % blue
color_mat(3,:)=[1,0.3,.5]; % magents
color_mat(4,:)=[.5,.2,1];  % purple

% Create the violin plot
h=figure;h.WindowState='maximized';
v=violinplot(data_matrix, {'Fast Subjects', 'Fast Trials','Slow Subjects',  'Slow Trials'});

% Customize the plot - set colors, add transparency, and display data points
% Set violin transparency and color
for i = 1:length(v)
    v(i).ViolinColor = {color_mat(i,:)};  
    v(i).ViolinAlpha = {0.2};  % Set violin transparency
    v(i).EdgeColor = color_mat(i,:);  % Remove the edge color
    hold on;
end

% Set plot labels and title
yticks(2.2:0.2:3.8);
ylabel('Single-trial EMG onset time (s)');
title('Violin Plot of EMG Onset Times for Fast and Slow Categories');
set(gca, 'fontsize', 32, 'fontweight', 'bold');

% Save the figure with high resolution
output_path = 'path to save plot';

%%_____________________________________________________________________________________________________________________
%% The violinplot code is adopted from: 
% Copyright (c) 2016, Bastian Bechtold
% This code is released under the terms of the BSD 3-clause license
% https://github.com/bastibe/Violinplot-Matlab
cd(output_path);
print('emg_times_comparison_violin.png', '-dpng', '-r500');

% Save computed EMG data
cd(file_path);
save('EMG_data_fast_slow_subtrl.mat', "emg_data");
save('EMG_data_detail_fast_slow_subtrl.mat', 'fast_subs_emgt', 'slow_subs_emgt', 'fast_trls_emgt', 'slow_trls_emgt');
