/* 
============================================================
ATP Tour Data Warehouse
Script: Gold Layer View — dim_players
Description: Player dimension table. One row per player.
             Sourced directly from silver.atp_players —
             no additional transformations applied at this stage.
             Adds calculated age column based on current date.
             Only players with at least one match record are included
             (filtered during silver load).
============================================================
*/

CREATE OR ALTER VIEW gold.dim_players AS 
SELECT
    id AS player_id,
    player AS full_name,
    birthdate,
    -- calculated at query time — reflects current age, not age at any specific match
    DATEDIFF(year, birthdate, GETDATE()) AS age,
    weight AS weight_kg,
    height AS height_cm,
    turnedpro AS turned_pro_date,
    birthplace,
    coaches,
    hand,
    backhand,
    ioc AS country_code
FROM silver.atp_players;