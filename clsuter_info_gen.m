% This code generates a file containing the index of components and subjects in each cluster.
clc; clear;

% Add paths to EEGLAB, code, and data directories
addpath('path to EEGlab');
addpath('path to data');
eeglab; close;

% Load the study and define study parameters
STUDY = pop_loadstudy('finger_pinching_study.study');
good_subjects = [3, 4, 5, 9, 13, 14, 19, 22, 23, 25, 27, 30, 35, 36, 46, 48, 49, 50, 52];
clusters = [3, 4, 7, 9, 10];
num_cls = length(clusters);

% Initialize cell arrays to store subject indices and component indices for each cluster
subjects = cell(1, num_cls);
components = cell(1, num_cls);

% Loop over clusters to get the subjects and components in each
for cls = 1:num_cls
    cluster_index = clusters(cls);
    subs_ind = STUDY.cluster(cluster_index).sets;
    subjects{cls} = good_subjects(subs_ind);
    components{cls} = STUDY.cluster(cluster_index).comps;
end

% Save the subjects and components data into a .mat file
output_path = 'path to save result';
cd(output_path);
save('MS_cls_info.mat', "subjects", "components");
