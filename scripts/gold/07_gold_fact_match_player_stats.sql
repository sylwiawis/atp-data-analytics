/* 
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — fact_match_player_stats
Description: Player-level fact table. One row per player per match (2 rows per match).
             Created by unpivoting silver.atp_matches — winner and loser rows
             are combined via UNION ALL into a single player-oriented structure.
             without needing to handle winner/loser columns separately in Power BI.
============================================================
*/

CREATE OR ALTER VIEW gold.fact_match_player_stats AS
WITH combined_win_lose AS (

    -- winner perspective
    SELECT
        match_id,
        winner_id AS player_id,
        tourney_id,
        surface,
        1 AS is_win,
        winner_seed AS seed,
        winner_entry AS entry_type,
        winner_age AS age_atm,
        winner_rank AS atp_ranking,
        winner_rank_points AS rank_points,
        w_ace AS aces,
        w_df AS double_faults,
        w_svpt AS service_points,
        w_1stIn AS first_serve_in,
        w_1stWon AS first_serve_won,
        w_2ndWon AS second_serve_won,
        w_SvGms AS service_games,
        w_bpSaved AS break_points_saved,
        w_bpFaced AS break_points_faced
    FROM silver.atp_matches

    UNION ALL

    -- loser perspective
    SELECT
        match_id,
        loser_id AS player_id,
        tourney_id,
        surface,
        0 AS is_win,
        loser_seed AS seed,
        loser_entry AS entry_type,
        loser_age AS age_atm,
        loser_rank AS atp_ranking,
        loser_rank_points AS rank_points,
        l_ace AS aces,
        l_df AS double_faults,
        l_svpt AS service_points,
        l_1stIn AS first_serve_in,
        l_1stWon AS first_serve_won,
        l_2ndWon AS second_serve_won,
        l_SvGms AS service_games,
        l_bpSaved AS break_points_saved,
        l_bpFaced AS break_points_faced
    FROM silver.atp_matches

)
SELECT * FROM combined_win_lose;