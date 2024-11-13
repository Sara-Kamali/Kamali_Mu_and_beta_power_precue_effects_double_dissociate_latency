% This function creates an event structure for EEG data, specifying whether a trial is for
% the left or right hand and indexing each trial.

function events = event_struct(pnt, cue_time, trial_num)

% Preallocate the structure with fields for each event
events = struct('type', [], 'epoch', [], 'latency', [], 'amplitude', NaN, 'duration', 0, 'urevent', []);

% Create events for right-hand trials
for i = 1:trial_num
    idx = 2 * i - 1;
    events(idx).type = sprintf('R%d', i);
    events(idx).epoch = i;
    events(idx).latency = (idx - 1) * pnt / 2 + 1;
    events(idx + 1).type = 'GoCue';
    events(idx + 1).epoch = i;
    events(idx + 1).latency = (idx - 1) * pnt / 2 + cue_time(1025) / 1000;
end

% Insert hand change event
change_idx = 2 * trial_num + 1;
events(change_idx).type = 'Hand change:right to left';
events(change_idx).epoch = trial_num + 1;
events(change_idx).latency = (change_idx - 1) * pnt / 2 + 1;

% Create events for left-hand trials
for i = 1:trial_num
    idx = 2 * (trial_num + i);
    events(idx).type = sprintf('L%d', i);
    events(idx).epoch = trial_num + i;
    events(idx).latency = (idx - 2) * pnt / 2 + 1;
    events(idx + 1).type = 'GoCue';
    events(idx + 1).epoch = trial_num + i;
    events(idx + 1).latency = (idx - 2) * pnt / 2 + cue_time(1025) / 1000;
end

% Finalize amplitude, duration, and urevent fields
for i = 1:numel(events)
    events(i).amplitude = NaN;
    events(i).duration = 0;
    events(i).urevent = i;
end

end