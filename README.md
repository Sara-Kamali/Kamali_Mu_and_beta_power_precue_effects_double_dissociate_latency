# Mu and Beta Power Effects

## 1. Introduction

This repository belongs to the codes for analysis and generating plots for:

Kamali S, Baroni F, Varona P. **Mu and beta power effects of fast response trait double dissociate during precue and movement execution in the sensorimotor cortex**. *bioRxiv*. 2024:2024-11. doi: [10.1101/2024.11.11.621252](https://doi.org/10.1101/2024.11.11.621252)

Using any of these codes or materials requires the authors’ permission. To refer to the results, please cite the work as listed above. All the codes are in Matlab.

---

## 2. Dataset

The dataset used in this study belongs to a stereotypical finger-pinching task and is publicly available at: [doi:10.1093/gigascience/gix034](https://doi.org/10.1093/gigascience/gix034). Figure 1 in the paper depicts the execution steps and timeline.

---

## 3. Preprocessing Pipeline

The codes to perform the preprocessing pipeline, shown in Figure 2 are:

- **Preprocessing shared with EEG and EMG**: `preprocessing.m`
- **Import channel locations**: `channel_locator.m`
- **Function to enter events field**: `event_struct.m`
- **Find the event where hand change from right to left happens**: `detect_hand_change.m`
- **Compute time-frequency decomposition of EMG single trials**: `EMG_ersp_singletrl.m`
- **Detect EMG onset latency**: `emg_onset_detector.m`
- **Select brain and eye dipoles to include in the study**: `dipfit_criteria.m`

---

## 4. Clustering ICs

To generate the STUDY for group-level analysis and perform clustering on brain dipoles and get the results in Figures 3 and 4, use the following codes:

- Create STUDY: `study_generator.m`
- Import the STUDY into EEGlab GUI. Set the parameters for the ERSP, ERP, and spectrum fields manually.
- Perform the pre-clustering calculations by adjusting the weights as recommended in the paper’s section 2.5 and select the ICs as recommended.
- Get the subjects and ICs’ indexes from the study: `cluster_info_gen.m`

---

## 5. Classification Based on Latency

To form the trait and state fast and slow groups based on latencies and generate Figure 5 and Tables 1 and 2, use the following codes:

- **Find the fast and slow subject and trials**: `find_fast_slow_subs.m`
- **Make a plot of the mean latencies for all the subjects and the violin plot for the latencies of the single trials both for trait and state**: `emg_onset_data_fast_slow_subtrls.m`
- **Find the fast and slow subjects and trials to extract the time-frequency of single trials for each brain area**: `fast_slow_subtrials_extract_for_t_test_analysis.m`
- **Do the same for the EMG data**: `fast_slow_subtrl_EMG_extract_for_ttest_analysis.m`

---

## 6. Statistical Tests

To perform cluster-based permutation t-tests and FDR correction and generate results presented in Figures 6 to 8, use the following codes:

- **Function to perform cluster-based permutation t-test**: `permutation_test_on_clusters.m`
- **Cluster-based test and FDR correction for EEG data over brain areas**: `cluster_based_permutation_test_fast_slow_subjects_trials.m`
- **Cluster-based test and FDR correction for EMG data**: `cluster_based_permutation_test_fast_slow_subjects_trials_EMG.m`
- **Function to plot the IQR shades**: `shade.m`
