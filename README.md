[readme_muandbeta.pdf](https://github.com/user-attachments/files/17970055/readme_muandbeta.pdf)
1 Introduction
This respiratory belongs to the codes for analysis and generating plots for: Kamali S, Baroni F, Varona P. Mu and beta power effects of fast response trait double dissociate during precue and movement execution in the senso- rimotor cortex. bioRxiv. 2024:2024-11. doi: 10.1101/2024.11.11.621252 Using any of these codes or materials requires authors’ permission, to refer to the results, please cite the work as listed above.
All the codes are in Matlab.
2 Dataset
The dataset used in this study belongs to a stereotypical finger-pinching task which is publicly available at: doi:10.1093/gigascience/gix034. Figure 1 in the paper depicts the execution steps and timeline.
3 Preprocessing pipeline
The codes to perform the preprocessing pipeline, shown in Figure 2 are:
4
• • • • • • •
Preprocessing shared with EEG and EMG: preprocessing.m
Import channel locations: channel locator.m
Function to enter events field: event struct.m
Find the event where hand change from right to left happens: detect hand change.m Compuet time-frequency decomposition of EMG single trials: EMG ersp singletrl.m Detect EMG onset latency emg onset detector.m
Select brain and eye dipoles to include in the study: dipfit criteria.m Clustering ICs
To generate the STUDY for group-level analysis and to perform clustering on brain dipoles and get the results in Fig 3 and Fig 4, use the following codes:
• Create STUDY: study generator.m 1

5
6
•
•
•
Import the STUDY into EEGlab GUI. Set the parameters for the ERSP, ERP and spectrum fields manually.
Perform the pre-clustering calculations by adjusting the weights as recommended in the papers’ section 2.5 and select the ICs as recom- mended.
Get the subjects and ICs’ indexes from the study:
clsuter info gen.m
Classification based on latency
Form the trait and state fast and slow groups based on latencies, to get these and generate Fig 5 and Tables 1 and 2, use the following codes.
• •
•
•
Find the fast and slow subject and trials: find fast slow subs.m
Make a plot of the mean latencies for all the subjects and the violin plot for the latencies of the single trials both for trait and state:
emg onset data fast slow subtrls.m
Find the fast and slow subjects and trials to extract the time-frequency of single trials, for each brain area:
fast slow subtrials extract for t test analysis.m
Do the same for the EMG data:
fast slow subtrl EMG extract for ttest analysis.m
Statistical tests
To perform cluster-based permutation t-test and F DR correction, to generate results presented in Fig 6 to 8, use the following codes.
• Function to perform cluster-based permutation t-test: permutation test on clusters.m
• Cluster-based test of EEG data over brain areas:
cluster based permutation test fast slow subjects trials.m
• Cluster-based test of EMG data:
cluster based permutation test fast slow subjects trials EMG.m
• Function to ploy the IQR shades: shade.m 2
