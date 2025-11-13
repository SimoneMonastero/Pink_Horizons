function     [p_walking, bout_starts, bout_ends, bout_durations, valid_bouts]=percentage_walking_func(walking,min_bout_duration_sec, limit)
    % Function to compute walking percentage and valid walking bouts
    
   % Identify transitions: 0 -> 1 (start) and 1 -> 0 (end)
    d = diff([0; walking; 0]);
    d = diff([0; walking; 0]);
    bout_starts = find(d == 1);
    bout_ends = find(d == -1) - 1;
    bout_durations = bout_ends - bout_starts + 1; % Duration in seconds (1-second windows)
    
    walking_final = zeros(limit, 1);
    valid_bouts = 0;

% Keep only bouts longer than the minimum duration
    for j = 1:length(bout_durations)
        if bout_durations(j) > min_bout_duration_sec
            walking_final(bout_starts(j):bout_ends(j)) = 1;
            valid_bouts = valid_bouts + 1;
        end
    end
    
    fprintf('Trovati %d bout di cammino > %d secondi.\n', valid_bouts, min_bout_duration_sec);
    
    % Compute final walking percentage
    p_walking = sum(walking_final) / length(walking_final) * 100;
    
    fprintf('Percentuale cammino finale (bout > %ds): %.2f %%\n', min_bout_duration_sec, p_walking);

end
