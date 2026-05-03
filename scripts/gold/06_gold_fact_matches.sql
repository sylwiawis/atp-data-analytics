/* 
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — fact_match
Description: Core fact table. One row per match.
             Sourced from silver.atp_matches with column renaming
             and derived columns:
               - duration_minutes: NULL for 0-minute non-walkover matches
               - duration_bucket: categorized match duration for Power BI filtering
               - match_status: Completed / Walkover / Retired based on score string
               - is_upset: 1 if lower-ranked player won
               - upset_category: magnitude of upset based on ranking difference
============================================================
*/

CREATE OR ALTER VIEW gold.fact_match AS 
SELECT
    match_id,
    tourney_id AS tournament_id,
    tourney_date,
    winner_id,
    loser_id,
    match_num AS match_number,
    surface,
    best_of AS max_sets,
    round_full_name AS round_name,
    round_sort_order AS round_order,
    score AS match_score,

    -- set duration to NULL for matches with 0 minutes that are not walkovers
    CASE 
        WHEN minutes_played <= 0 AND score != 'W/O' THEN NULL
        ELSE minutes_played
    END AS duration_minutes,

    -- categorized duration for Power BI slicing
    CASE
        WHEN minutes_played IS NULL THEN 'Unknown'
        WHEN minutes_played < 60 THEN 'Under 1 hour'
        WHEN minutes_played < 120 THEN 'Between 1 and 2 hours' 
        WHEN minutes_played < 180 THEN 'Between 2 and 3 hours' 
        WHEN minutes_played < 270 THEN 'Between 3 and 4 hours' 
        ELSE 'Over 4 hours'
    END AS duration_bucket,

    -- match completion status derived from score string
    CASE
        WHEN score LIKE '%W/O%' THEN 'Walkover'
        WHEN score LIKE '%RET%' THEN 'Retired'
        ELSE 'Completed'
    END AS match_status,

    -- 1 if lower-ranked player won (upset)
    CASE 
        WHEN winner_rank > loser_rank THEN 1 
        ELSE 0 
    END AS is_upset,

    -- upset magnitude based on ranking difference between winner and loser
    CASE 
        WHEN winner_rank - loser_rank > 50 THEN 'Big upset'
        WHEN winner_rank - loser_rank > 20 THEN 'Upset'
        WHEN winner_rank - loser_rank > 0 THEN 'Small upset'
        ELSE 'Expected result'
    END AS upset_category

FROM silver.atp_matches;