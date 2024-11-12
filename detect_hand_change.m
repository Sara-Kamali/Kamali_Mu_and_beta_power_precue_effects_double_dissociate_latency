% Find where the hand change occures in EEG data
function [Hand_change_trial_ind] = detect_hand_change(EEG)

prevHand='R1';currentHand='R1';

for i=1:length(EEG.event)
    if strcmp(EEG.event(i).type,'Hand change:right to left')
        Hand_change_trial_ind=(EEG.event(i).urevent+1)/2;break
    elseif ~strcmp(EEG.event(i).type,'GoCue')
        prevHand=currentHand;currentHand=EEG.event(i).type;
        if currentHand(1)~=prevHand(1);Hand_change_trial_ind=EEG.event(i).urevent/2;break;end
    end
end