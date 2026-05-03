/*
============================================================
ATP Tour Data Warehouse
Script: Gold Layer Quality Checks
Description: Validates gold layer views after silver load.
             Checks row counts, referential integrity and
             that derived columns were calculated correctly.
             Run after: all gold views are created
============================================================

*/

-- Row counts
SELECT COUNT(*) AS total_matches FROM gold.fact_match;
SELECT COUNT(*) AS total_player_match_rows FROM gold.fact_match_player_stats;
SELECT COUNT(*) AS total_players FROM gold.dim_players;
SELECT COUNT(*) AS total_tournaments FROM gold.dim_tournaments;

-- fact_match_player_stats should have exactly 2 rows per match (winner + loser)
SELECT match_id, COUNT(*) AS player_count
FROM gold.fact_match_player_stats
GROUP BY match_id
HAVING COUNT(*) != 2;

-- Each match should have exactly one winner
SELECT match_id, SUM(is_win) AS win_count
FROM gold.fact_match_player_stats
GROUP BY match_id
HAVING SUM(is_win) != 1;

-- Check round names and sort order — verify mapping applied correctly
SELECT DISTINCT round_name, round_order
FROM gold.fact_match
ORDER BY round_order;

-- Check for matches with negative or zero duration that are not walkovers
-- should be empty after silver fix
SELECT COUNT(*) AS invalid_duration
FROM gold.fact_match
WHERE duration_minutes <= 0 
AND match_status != 'Walkover';

-- Check ranking points are positive where not NULL
SELECT COUNT(*) AS negative_rank_points
FROM gold.fact_match_player_stats
WHERE rank_points < 0;

-- Referential integrity
SELECT DISTINCT player_id FROM gold.fact_match_player_stats
WHERE player_id NOT IN (SELECT player_id FROM gold.dim_players);

SELECT DISTINCT tournament_id FROM gold.fact_match
WHERE tournament_id NOT IN (SELECT Tournament_ID FROM gold.dim_tournaments);

SELECT DISTINCT match_id FROM gold.fact_match_player_stats
WHERE match_id NOT IN (SELECT match_id FROM gold.fact_match);

-- Break points saved fix — should return 0 rows
SELECT COUNT(*) AS invalid_bp FROM gold.fact_match_player_stats
WHERE break_points_saved > break_points_faced;

-- Check derived columns
SELECT DISTINCT upset_category FROM gold.fact_match;
SELECT DISTINCT match_status FROM gold.fact_match;
SELECT DISTINCT duration_bucket FROM gold.fact_match ORDER BY duration_bucket;
SELECT DISTINCT is_upset FROM gold.fact_match;
SELECT DISTINCT round_name, round_order FROM gold.fact_match ORDER BY round_order;