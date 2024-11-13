% This function processes raw four-channel EMG signals, computes bipolar EMG 
% for each hand, extracts EMG onset times, filters out bad trials, and assesses 
% EMG quality. If more than 50% of trials are removed the EMG recording quality 
% is not good. In this case, we will remove the subject from the analysis.

function [bipolar_emg, emg_onset, good_trials, emg_quality] = ...
    emg_onset_detector(emg_data, good_eeg_trials, t_start, t_end, t_800, time_vec)

% Define low-pass filter cutoff for EMG signal to improve SNR
f_high = 200; % 200 Hz low-pass FIR filter
EMG = pop_eegfiltnew(emg_data, 'hicutoff', f_high, 'plotfreqz', 0);

% Initialize variables for EMG onset times and trial quality assessment
num_trials = length(good_eeg_trials);
emg_onset = NaN(1, num_trials);

% Compute bipolar EMG signals to reduce artifacts
bipolar_emg_right = squeeze(abs(EMG.data(3,:,1:20) - EMG.data(4,:,1:20)));
bipolar_emg_left = squeeze(abs(EMG.data(1,:,21:40) - EMG.data(2,:,21:40)));
bipolar_emg = [bipolar_emg_right,bipolar_emg_left];% Merge the right and left hand
bipolar_emg = bipolar_emg(:,good_eeg_trials);

% Define window size for moving average filter
window_size =15; % Trial and error based

% Initialize matrices for storing EMG signals and standard deviations
biemg = zeros(num_trials,EMG.pnts);
std_pre_cue = zeros(num_trials, 1);
std_post_cue = zeros(num_trials, 1);

% Detect EMG onset for each trial
for trl = 1:num_trials
    biemg(trl, :) = squeeze(bipolar_emg(:, trl));
    std_pre_cue(trl) = std(biemg(trl,t_800:t_start),1); % Pre-cue standard deviation
    std_post_cue(trl) = std(biemg(trl,t_start:t_end),1); % Execution phase standard deviation
    
    % Compute moving mean of bipolar EMG signal
    bp_emg_mm = movmean(biemg(trl, :), window_size);
    
    % Detect onset when signal exceeds 25% of maximum in execution phase
    t_onset = find(bp_emg_mm(t_start:t_end) >= 0.25 * max(bp_emg_mm(t_start:t_end)), 1) + t_start;
    
    % Set onset time if signal passes threshold and meets noise criteria
    if ~isempty(t_onset) && std_pre_cue(trl) < std_post_cue(trl)/3
        emg_onset(trl) = t_onset;
    end
end

% Identify outlier trials based on EMG onset interquartile range (IQR)
fast_react_lim = 25;
slow_react_lim = 75;
q1 = prctile(emg_onset, fast_react_lim);
q3 = prctile(emg_onset, slow_react_lim);
IQR = min(max(q3 - q1,100), 150); % Bound IQR between 100 and 150

% Filter good trials by excluding outliers and NaN values
good_trials = find(~isnan(emg_onset) & ...
                   emg_onset >= (q1 - 2 * IQR) & ...
                   emg_onset <= (q3 + 2 * IQR));

% Convert EMG onset times from sample indices to seconds
emg_onset(~isnan(emg_onset)) = time_vec(emg_onset(~isnan(emg_onset)));

% Assess EMG recording quality based on proportion of good trials
if length(good_trials) > num_trials / 2
    emg_quality = 'good';
else
    emg_quality = 'bad';
end

end
