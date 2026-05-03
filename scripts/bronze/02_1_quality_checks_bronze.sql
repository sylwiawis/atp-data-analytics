/* 
============================================================
ATP Tour Data Warehouse
Script: Bronze Layer Quality Checks — Players and Matches
Description: Validates raw data before silver transformation.
             Documents known issues and planned fixes for silver load.
             Run after: bronze.load_bronze
============================================================
*/

-- ============================================================
-- PLAYERS
-- ============================================================

SELECT TOP 10 * FROM bronze.atp_players;
SELECT COUNT(*) AS total_players FROM bronze.atp_players;

-- duplicates and NULLs
SELECT id, COUNT(*) FROM bronze.atp_players GROUP BY id HAVING COUNT(*) > 1;
SELECT COUNT(*) AS null_id FROM bronze.atp_players WHERE id IS NULL;
SELECT COUNT(*) AS null_player FROM bronze.atp_players WHERE player IS NULL;
SELECT * FROM bronze.atp_players WHERE player != TRIM(player);

-- categorical columns — expected values documented for silver standardization
SELECT DISTINCT hand FROM bronze.atp_players; -- R, L, A → full names in silver
SELECT DISTINCT backhand FROM bronze.atp_players; -- 1H, 2H → full names in silver
SELECT DISTINCT ioc FROM bronze.atp_players ORDER BY ioc;

-- outliers — out-of-range values set to NULL in silver
SELECT * FROM bronze.atp_players WHERE height < 100 OR height > 240;
SELECT * FROM bronze.atp_players WHERE weight < 50 OR weight > 150; -- some rows contain birthdates in weight column — fixed in silver

-- other data issues
SELECT * FROM bronze.atp_players WHERE player LIKE 'Unknown%'; -- filtered out in silver
SELECT * FROM bronze.atp_players WHERE turnedpro < birthdate;
SELECT * FROM bronze.atp_players WHERE birthdate > GETDATE();
SELECT COUNT(*) AS missing_ioc FROM bronze.atp_players WHERE ioc IS NULL;


-- ============================================================
-- MATCHES
-- ============================================================

SELECT TOP 10 * FROM bronze.atp_matches;
SELECT COUNT(*) AS total_matches FROM bronze.atp_matches;

-- NULLs in key columns
SELECT COUNT(*) AS null_tourney_id FROM bronze.atp_matches WHERE tourney_id IS NULL;
SELECT COUNT(*) AS null_winner_id FROM bronze.atp_matches WHERE winner_id IS NULL;
SELECT COUNT(*) AS null_tourney_date FROM bronze.atp_matches WHERE tourney_date IS NULL;

-- unwanted spaces
SELECT winner_id FROM bronze.atp_matches WHERE winner_id != TRIM(winner_id);
SELECT loser_id FROM bronze.atp_matches WHERE loser_id != TRIM(loser_id);

-- categorical columns
SELECT DISTINCT indoor FROM bronze.atp_matches; -- O/I → Outdoor/Indoor in silver
SELECT DISTINCT surface FROM bronze.atp_matches; -- NULLs → Unknown in silver
SELECT DISTINCT winner_hand FROM bronze.atp_matches; -- R/L/A → full names in silver
SELECT DISTINCT loser_hand FROM bronze.atp_matches;
SELECT DISTINCT winner_ioc FROM bronze.atp_matches ORDER BY winner_ioc;
SELECT DISTINCT loser_ioc FROM bronze.atp_matches ORDER BY loser_ioc;
SELECT DISTINCT round_name FROM bronze.atp_matches;  -- full names added in silver
SELECT DISTINCT tourney_level FROM bronze.atp_matches; -- standardized in silver
SELECT DISTINCT winner_entry FROM bronze.atp_matches;
SELECT DISTINCT loser_entry FROM bronze.atp_matches;

-- outliers
SELECT * FROM bronze.atp_matches WHERE winner_age > 50 OR winner_age < 14 OR loser_age > 50 OR loser_age < 14;
SELECT COUNT(*) AS zero_duration_non_walkover FROM bronze.atp_matches WHERE minutes_played <= 0 AND score NOT LIKE '%W/O%';
SELECT COUNT(*) AS null_scores FROM bronze.atp_matches WHERE score IS NULL;
SELECT COUNT(*) AS same_player_matches FROM bronze.atp_matches WHERE winner_id = loser_id;

-- break points saved > faced (impossible value) — set to NULL in silver
SELECT COUNT(*) AS invalid_bp_winner FROM bronze.atp_matches WHERE w_bpSaved > w_bpFaced;
SELECT COUNT(*) AS invalid_bp_loser FROM bronze.atp_matches WHERE l_bpSaved > l_bpFaced;


-- ============================================================
-- KNOWN DATA ISSUES — investigated and resolved in silver
-- ============================================================

-- Davis Cup: same match under multiple IDs — consolidated in silver
SELECT DISTINCT tourney_name FROM bronze.atp_matches WHERE tourney_name LIKE 'Davis Cup%' ORDER BY tourney_name;

-- duplicate matches — resolved via ROW_NUMBER() deduplication in silver
SELECT tourney_id, winner_id, loser_id, score, COUNT(*) AS duplicate_count
FROM bronze.atp_matches
GROUP BY tourney_id, winner_id, loser_id, score
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- players with same name but multiple IDs
-- Martin Damm — two different players, no fix needed
-- Harshana Godamanna — ID and IOC corrected in silver
-- Marc-Andrea Huesler — incorrect record excluded in silver
SELECT 
    winner_name AS player_name, 
    COUNT(DISTINCT winner_id) AS id_count,
    STRING_AGG(CAST(winner_id AS VARCHAR), ', ') AS ids_list
FROM bronze.atp_matches
GROUP BY winner_name
HAVING COUNT(DISTINCT winner_id) > 1
ORDER BY id_count DESC;