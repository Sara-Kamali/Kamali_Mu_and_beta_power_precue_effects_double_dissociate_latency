good_subs=[3,4,5,9,13,14,19,22,23,25,27,30,35,36,46,48,49,50,52];
%init_subs=[1,3,4,5,6,9:15,18,19,21:28,30,31,33,35,36,37,39,41:44,46,48,49,50,52];
excluded_subs=[1,6,10,11,12,15,18,21,24,26,28,31,33,37,39,41:44];
ages = [24,29,23,31,20,27,26,20,24,18,21,25,26,27,25,28,27,29,24,32,20,19,19,...
    25,25,26,33,19,20,29,28,23,29,27,30,25,26,26,23,28,23,30,20,19,19,19,23,...
    26,28,24,28,25];
time_slot=[1,2,3,1,2,3,4,1,2,3,4,2,3,4,1,2,4,1,2,4,1,2,3,4,2,3,4,4,3,4,3,4,3,...
    2,3,1,3,2,3,4,3,4,1,2,3,4,1,2,4,3,1,4];
gender = [0,1,0,1,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,1,1,1,1,0,1,1,1,1,1,1,0,0,...
    1,1,1,0,1,0,0,0,1,0,1,1,1,0,0,0,1,1,1];
BCI_experience=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,...
    0,0,0,1,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,1,10,4];
Biofeedback_experience=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,...
    0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
sleep_hrs=[2,1,2,1,3,3,1,5,2,5,4,2,4,4,2,4,2,4,2,4,1,5,2,3,2,3,4,3,3,3,4,2,...
    2,3,1,3,3,5,2,4,4,2,3,4,4,3,3,3,4,3,3,4];
coffee=[12,2,20,2,17,16,11,0,0,0,0,0,0,5,0,0,0,12,0,7,23,0,30,0,7,0,0,2,0,0,...
    4,0	4,0,2,0,0,0,5,6,0,0,0,22,0,0,0,0,1,0,0,0];
anxious=[3	3	1	1	3	1	3	3	2	4	3	3	3	1	1	1	3 ...
    2	1	2	3	1	1	2	2	2	2	3	1	2	1	3	3	3	1	...
    2	1	1	3	2	2	2	3	4	2	2	1	2	2	2	2	1];

bored =[2	3	2	3	1	3	2	3	3	4	3	4	3	2	2	1	3 ...
    2	2	3	5	3	3	2	3	4	3	3	1	1	2	2	3	2	3 ...
    3	3	4	3	2	2	2	3	4	3	4	2	4	1	2	2	2];

distract = [2	4	2	3	3	2	3	4	3	3	3	2	1	3	3	2	...
    3	3	2	3	4	2	2	3	2	3	4	4	2	3	3	2	3	4	...
    4	2	2	3	3	3	2	3	3	5	2	2	2	4	2	2	2	1];

physical_tiredness = [2	3	3	2	3	1	4	1	2	3	3	2	1	3	3	1	...
    2	2	1	3	3	2	4	1	4	2	3	3	2	2	2	2	4	4	...
    4	2	2	2	3	3	3	3	4	3	3	3	2	3	1	3	2	1];

mental_tiredness=[2	4	2	2	2	1	4	1	2	3	2	1	2	3	2	...
    1	3	2	1	3	3	1	2	1	3	2	3	2	2	2	1	2	3	...
    3	4	2	2	4	3	3	3	3	3	3	3	4	2	3	1	3	2	1];


 
% Define attribute names and corresponding arrays
attribute_names = { 'Age', 'TimeSlot', 'Gender', 'BCI_Exp', 'Biofeedback_Exp', ...
    'Sleep_Hrs', 'Coffee', 'Anxious', 'Bored', 'Distract', 'Phys_Tired', 'Ment_Tired' };

attributes = {
    ages, time_slot, gender, BCI_experience, Biofeedback_experience, ...
    sleep_hrs, coffee, anxious, bored, distract, physical_tiredness, mental_tiredness
};

% Initialize results
n = numel(attribute_names);
Good_Mean = zeros(n,1);
Good_Std = zeros(n,1);
Excluded_Mean = zeros(n,1);
Excluded_Std = zeros(n,1);

% Calculate statistics
for i = 1:n
    data = attributes{i};
    Good_Mean(i) = mean(data(good_subs));
    Good_Std(i) = std(data(good_subs));
    Excluded_Mean(i) = mean(data(excluded_subs));
    Excluded_Std(i) = std(data(excluded_subs));
end

% Create comparison table
ComparisonTable = table(attribute_names', Good_Mean, Good_Std, Excluded_Mean, Excluded_Std, ...
    'VariableNames', {'Attribute', 'Good_Mean', 'Good_Std', 'Excluded_Mean', 'Excluded_Std'});

disp(ComparisonTable);







