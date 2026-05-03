/*
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — player_ranking_trend
Description: Ranking points trend per player with moving averages.
             One row per player per match, ordered chronologically.
             tourney_date and round_order joined from fact_match —
             needed because fact_match_player_stats has no date column.

Moving averages:
  moving_avg_10 — average rank points over last 10 matches (short-term form)
  moving_avg_20 — average rank points over last 20 matches (long-term trend)
  Both use ROWS BETWEEN N PRECEDING AND CURRENT ROW to ensure
  only past and current matches are included, not future ones.
============================================================

*/

CREATE OR ALTER VIEW gold.player_ranking_trend AS
SELECT 
    s.player_id,
    s.rank_points, 
    m.tourney_date,
    s.match_id,
    AVG(s.rank_points) OVER (
        PARTITION BY s.player_id 
        ORDER BY m.tourney_date, m.round_order
        ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
    ) AS moving_avg_10,
    AVG(s.rank_points) OVER (
        PARTITION BY s.player_id 
        ORDER BY m.tourney_date, m.round_order
        ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
    ) AS moving_avg_20
FROM gold.fact_match_player_stats s
LEFT JOIN gold.fact_match m ON s.match_id = m.match_id;


/*
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — player_aces_trend
Description: Aces per match trend per player with 10-match moving average.
             Used to visualize serving consistency over career.
             CAST to FLOAT ensures decimal precision in the moving average
             (AVG on INT would return INT and lose precision).
             tourney_date and round_order joined from fact_match for
             correct chronological ordering within tournaments.
============================================================
*/

CREATE OR ALTER VIEW gold.player_aces_trend AS
SELECT
    s.player_id,
    s.match_id,
    s.aces,
    m.tourney_date,
    m.round_order,
    AVG(CAST(s.aces AS FLOAT)) OVER (
        PARTITION BY s.player_id
        ORDER BY m.tourney_date, m.round_order
        ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
    ) AS moving_avg_aces
FROM gold.fact_match_player_stats s
JOIN gold.fact_match m ON s.match_id = m.match_id;