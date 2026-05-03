/*
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — dim_tournaments
Description: Tournament dimension table. One row per tournament.
             silver.atp_matches contains one row per match, so a single
             tournament appears thousands of times. This view collapses
             all matches into one representative row per tourney_id
             by selecting the most recent match in each tournament
             (ORDER BY tourney_date DESC, flag = 1).
             Davis Cup was already consolidated to a single tourney_id
             per year in silver, so it naturally produces one row here.
============================================================
*/

CREATE OR ALTER VIEW gold.dim_tournaments AS
WITH davis_organized AS (
    SELECT
        tourney_id,
        tourney_year,
        tourney_name,
        surface,
        tourney_level,
        draw_size,
        indoor,
        tourney_date,
        -- rank matches within each tournament by date descending
        -- flag = 1 selects the most recent match as the tournament representative
        ROW_NUMBER() OVER (PARTITION BY tourney_id ORDER BY tourney_date DESC) AS flag
    FROM silver.atp_matches
)
SELECT 
    tourney_id AS Tournament_ID,
    tourney_year AS Tournament_Year,
    tourney_name AS Tournament_Name,
    surface AS Surface,
    tourney_level AS Tournament_Level,
    draw_size AS Draw_Size,
    indoor AS Venue_Type,
    tourney_date AS Start_Date
FROM davis_organized
WHERE flag = 1;