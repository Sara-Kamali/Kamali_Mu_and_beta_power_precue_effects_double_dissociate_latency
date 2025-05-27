% Compare Attributes Between Initial Subjects and the good subjects (included in the study) 
% -----------------------------------------------------------------------

% Indices of good and initial subjects
% These are indices of 'initial' participants and "good" subjects, selected after preprocessing
good_subs = [3,4,5,9,13,14,19,22,23,25,27,30,35,36,46,48,49,50,52];
init_subs = [1,3,4,5,6,9:15,18,19,21:28,30,31,33,35,36,37,39,41:44,46,48,49,50,52];

% Attribute data for each of the 52 subjects, from meta-data of the source dataset file
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
    0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
sleep_hrs=[2,1,2,1,3,3,1,5,2,5,4,2,4,4,2,4,2,4,2,4,1,5,2,3,2,3,4,3,3,3,4,2,...
    2,3,1,3,3,5,2,4,4,2,3,4,4,3,3,3,4,3,3,4];
coffee=[12,2,20,2,17,16,11,0,0,0,0,0,0,5,0,0,0,12,0,7,23,0,30,0,7,0,0,2,0,0,...
    4,0,4,0,2,0,0,0,5,6,0,0,0,22,0,0,0,0,1,0,0,0];
anxious=[3,3,1,1,3,1,3,3,2,4,3,3,3,1,1,1,3,...
    2,1,2,3,1,1,2,2,2,2,3,1,2,1,3,3,3,1,...
    2,1,1,3,2,2,2,3,4,2,2,1,2,2,2,2,1];
bored =[2,3,2,3,1,3,2,3,3,4,3,4,3,2,2,1,3,...
    2,2,3,5,3,3,2,3,4,3,3,1,1,2,2,3,2,3,...
    3,3,4,3,2,2,2,3,4,3,4,2,4,1,2,2,2];
distract = [2,4,2,3,3,2,3,4,3,3,3,2,1,3,3,2,...
    3,3,2,3,4,2,2,3,2,3,4,4,2,3,3,2,3,4,...
    4,2,2,3,3,3,2,3,3,5,2,2,2,4,2,2,2,1];
physical_tiredness = [2,3,3,2,3,1,4,1,2,3,3,2,1,3,3,1,...
    2,2,1,3,3,2,4,1,4,2,3,3,2,2,2,2,4,4,...
    4,2,2,2,3,3,3,3,4,3,3,3,2,3,1,3,2,1];
mental_tiredness = [2,4,2,2,2,1,4,1,2,3,2,1,2,3,2,...
    1,3,2,1,3,3,1,2,1,3,2,3,2,2,2,1,2,3,...
    3,4,2,2,4,3,3,3,3,3,3,3,4,2,3,1,3,2,1];

% Define names and values of all attributes in a cell array for processing
attribute_names = { 'Age', 'TimeSlot', 'Gender', 'BCI_Exp', 'Biofeedback_Exp', ...
    'Sleep_Hrs', 'Coffee', 'Anxious', 'Bored', 'Distract', 'Phys_Tired', 'Ment_Tired' };

attributes = {
    ages, time_slot, gender, BCI_experience, Biofeedback_experience, ...
    sleep_hrs, coffee, anxious, bored, distract, physical_tiredness, mental_tiredness
};

% Initialize result arrays to hold mean and std for each attribute in both groups
n = numel(attribute_names);
Good_Mean = zeros(n,1);
Good_Std = zeros(n,1);
Init_Mean = zeros(n,1);
Init_Std = zeros(n,1);

% Compute statistics per attribute
for i = 1:n
    data = attributes{i};
    Good_Mean(i) = mean(data(good_subs));      % Mean for good group
    Good_Std(i) = std(data(good_subs));        % Std for good group
    Init_Mean(i) = mean(data(init_subs));      % Mean for initial group
    Init_Std(i) = std(data(init_subs));        % Std for initial group
end

% Combine results into a single comparison table
ComparisonTable = table(attribute_names', Good_Mean, Good_Std, Init_Mean, Init_Std, ...
    'VariableNames', {'Attribute', 'Good_Mean', 'Good_Std', 'Init_Mean', 'Init_Std'});

% Display the result table
disp(ComparisonTable);
