% This Function selects brain and eye ICs with probability > prob_trshld and residual variance (RV) < RV_trshld,
% and saves the indices of selected components into `etc.good_components` field.

function EEG_out = dipfit_criteria(EEG_in, prob_trshld, RV_trshld)


EEG_out = EEG_in;
EEG_out.components_to_cluster = struct; % Initialize new field
good_components = [];
brain_components = [];

% Iterate over all channels except the last one
for i = 1:EEG_in.nbchan - 1
    % Extract the highest probability classification for the current IC
    [max_probability, max_index] = max(EEG_in.etc.ic_classification.ICLabel.classifications(i, :));
    
    % Check if the component meets the selection criteria (indexes 1 and 3 belong to eye and
    % brain componenets in IC labeling)
    if (max_index == 1 || max_index == 3) && (max_probability >= prob_trshld) && ...
        (EEG_in.dipfit.model(i).rv <= RV_trshld)
        good_components = [good_components, i];
    end
    
    % Count and identify the brain components
    if max_index == 1 && (max_probability >= prob_trshld) && (EEG_in.dipfit.model(i).rv <= RV_trshld)
        brain_components = [brain_components, i];
    end
end

% Save selected components into the new fields
EEG_out.components_to_cluster.good_comps = good_components;
EEG_out.components_to_cluster.brain_comps = brain_components;

end
