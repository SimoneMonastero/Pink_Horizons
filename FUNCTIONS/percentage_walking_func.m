function     [p_walking]=percentage_walking_func(walking,min_bout_duration_sec)
    % --- 7. Bout validi (>60s) ---
    % Trova transizioni 0->1 (start) e 1->0 (end)
    d = diff([0; walking; 0]);
    bout_starts = find(d == 1);
    bout_ends = find(d == -1) - 1;
    bout_durations = bout_ends - bout_starts + 1; % Durata in secondi (finestre da 1s)
    
    walking_final = zeros(limit, 1);
    valid_bouts = 0;

    for j = 1:length(bout_durations)
        if bout_durations(j) > min_bout_duration_sec
            walking_final(bout_starts(j):bout_ends(j)) = 1;
            valid_bouts = valid_bouts + 1;
        end
    end
    
    fprintf('Trovati %d bout di cammino > %d secondi.\n', valid_bouts, min_bout_duration_sec);
    
    % --- 8. Percentuale cammino ---
    p_walking = sum(walking_final) / length(walking_final) * 100;
    
    fprintf('Percentuale cammino finale (bout > %ds): %.2f %%\n', min_bout_duration_sec, p_walking);
end