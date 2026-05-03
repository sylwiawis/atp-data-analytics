/* 
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — win_streak
Description: Calculates consecutive win and loss streaks per player.
             Walkovers excluded — streaks should reflect actual match performance.

Streak detection logic:
             Two ROW_NUMBER() window functions are computed per player:
             (1) overall match sequence ordered by date and round
             (2) sequence within each result type (win/loss) separately
             The difference between (1) and (2) remains constant within
             a consecutive streak and changes when the streak breaks —
             this constant difference becomes the streak_group identifier.

Output: one row per streak per player, with start date, end date,
        length and whether it was a winning (is_win=1) or losing (is_win=0) streak
============================================================
*/

CREATE OR ALTER VIEW win_streak AS 
WITH match_sequence AS (
    SELECT
        s.player_id,
        s.match_id,
        m.tourney_date,
        s.is_win,
        -- overall match sequence per player
        ROW_NUMBER() OVER (PARTITION BY s.player_id ORDER BY m.tourney_date, m.round_order DESC) -
        -- sequence per player per result type (win or loss)
        ROW_NUMBER() OVER (PARTITION BY s.player_id, s.is_win ORDER BY m.tourney_date, m.round_order DESC)
        AS streak_group
    FROM gold.fact_match_player_stats s
    LEFT JOIN gold.fact_match m ON s.match_id = m.match_id
    WHERE m.match_score NOT LIKE '%W/O%'  -- exclude walkovers
),
streaks AS (
    SELECT
        player_id,
        MIN(tourney_date) AS streak_start,
        MAX(tourney_date) AS streak_end,
        COUNT(*) AS streak_length,
        is_win
    FROM match_sequence
    GROUP BY player_id, streak_group, is_win
)
SELECT
    player_id,
    streak_start,
    streak_end,
    streak_length,
    is_win
FROM streaks;

