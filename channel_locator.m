% This function sets the locations of EEG and EMG channels based on input XYZ coordinates.
function chan_loc_xyz = channel_locator(xyz)

% Define channel labels
labels = {'Fp1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', ...
    'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', ...
    'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', ...
    'Pz', 'CPz', 'Fpz', 'Fp2', 'AF8', 'AF4', 'Afz', 'Fz', 'F2', 'F4', ...
    'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', ...
    'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', ...
    'P10', 'PO8', 'PO4', 'O2', 'Left EMG1', 'Left EMG2', 'Right EMG1', 'Right EMG2'};

% Preallocate chan_loc_xyz with all required fields to avoid dissimilar structures issue
chan_loc_xyz = repmat(struct('labels', [], 'X', [], 'Y', [], 'Z', [], 'theta', [], ...
                             'radius', [], 'sph_theta', [], 'sph_phi', [], 'sph_radius', [], ...
                             'type', [], 'urchan', [], 'ref', 'average'), 1, 68);

% Assign EEG channels (1-64)
for i = 1:64
    chan_loc_xyz(i) = set_channel_fields(labels{i}, xyz(i, :), 'EEG', i);
end

% Assign EMG channels (65-68) with placeholder coordinates
for i = 65:68
    chan_loc_xyz(i) = set_channel_fields(labels{i}, [1000, 1000, 1000], 'EMG', i);
end


end



% Helper function to set fields for each channel
function channel = set_channel_fields(label, coords, type, index)
channel.labels = label;
channel.X = coords(2);
channel.Y = -coords(1);
channel.Z = coords(3);
channel.theta = [];
channel.radius = [];
channel.sph_theta = [];
channel.sph_phi = [];

% Set spherical radius based on channel type
if strcmp(type, 'EEG')
    channel.sph_radius = 1;
else
    channel.sph_radius = [];
end

channel.type = type;
channel.urchan = index;
channel.ref = 'average';
end


