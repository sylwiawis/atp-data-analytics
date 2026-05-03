/*
============================================================
ATP Tour Data Warehouse
Script: Silver Layer Quality Checks — Players & Matches
Description: Validates cleaned data after silver transformation.
             Checks that cleaning rules were applied correctly
             and that referential integrity between tables holds.
             Run after: silver.load_silver and silver.load_silver_players
============================================================
*/

-- ============================================================
-- PLAYERS
-- ============================================================

SELECT TOP 10 * FROM silver.atp_players;
SELECT COUNT(*) AS total_players FROM silver.atp_players;

-- Check for duplicate player IDs
SELECT id, COUNT(*)
FROM silver.atp_players
GROUP BY id
HAVING COUNT(*) > 1;

-- Check for NULLs in key columns
SELECT COUNT(*) AS null_id FROM silver.atp_players WHERE id IS NULL;
SELECT COUNT(*) AS null_player FROM silver.atp_players WHERE player IS NULL;

-- Check height and weight outliers 
SELECT * FROM silver.atp_players
WHERE height < 100 OR height > 240;

SELECT * FROM silver.atp_players
WHERE weight < 40 OR weight > 120;

-- Check hand values — expected: Right-Handed, Left-Handed, Ambidextrous, Unknown only
SELECT DISTINCT hand FROM silver.atp_players;

-- Check backhand values — expected: One-Handed, Two-Handed, Unknown only
SELECT DISTINCT backhand FROM silver.atp_players;

-- Check for unknown players — should be empty after silver filtering
SELECT * FROM silver.atp_players
WHERE player LIKE 'Unknown%';

-- Check IOC codes — all should be exactly 3 characters or 'N/A'
SELECT DISTINCT ioc FROM silver.atp_players
WHERE LEN(ioc) != 3 AND ioc != 'N/A';

-- Check for players who turned pro before birthdate — should be empty after silver fix
SELECT * FROM silver.atp_players
WHERE turnedpro < birthdate;


-- ============================================================
-- REFERENTIAL INTEGRITY
-- ============================================================

-- Check for winners and losers in matches not present in players table
-- ideally empty — any results indicate missing player records
SELECT DISTINCT winner_id
FROM silver.atp_matches
WHERE winner_id NOT IN (SELECT id FROM silver.atp_players);

SELECT DISTINCT loser_id
FROM silver.atp_matches
WHERE loser_id NOT IN (SELECT id FROM silver.atp_players);


-- ============================================================
-- MATCHES
-- ============================================================

SELECT TOP 10 * FROM silver.atp_matches;

-- Total row count — compare with bronze to verify if deduplication worked
SELECT COUNT(*) AS total_matches FROM silver.atp_matches;

-- Check for duplicate match IDs — none expected
SELECT match_id, COUNT(*)
FROM silver.atp_matches
GROUP BY match_id
HAVING COUNT(*) > 1;

-- Check for duplicate matches after deduplication
SELECT tourney_id, winner_id, loser_id, score, COUNT(*) AS duplicate_count
FROM silver.atp_matches
GROUP BY tourney_id, winner_id, loser_id, score
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Check categorical columns — verify standardization applied correctly
SELECT DISTINCT indoor FROM silver.atp_matches; -- expected: Indoor, Outdoor, Unknown
SELECT DISTINCT surface FROM silver.atp_matches; -- expected: Hard, Clay, Grass, Carpet, Unknown
SELECT DISTINCT winner_hand FROM silver.atp_matches; -- expected: Right-Handed, Left-Handed, Ambidextrous, Unknown
SELECT DISTINCT loser_hand FROM silver.atp_matches; -- expected: Right-Handed, Left-Handed, Ambidextrous, Unknown
SELECT DISTINCT tourney_level FROM silver.atp_matches; -- expected: Grand Slam, ATP Masters 1000, ATP 500, etc.
SELECT DISTINCT winner_entry FROM silver.atp_matches; -- expected: Wild Card, Qualifier, etc.
SELECT DISTINCT round_full_name FROM silver.atp_matches -- expected: Final, Semi-Finals, etc.

-- Check for matches with 0 minutes that are not walkovers — should be empty after silver fix
SELECT COUNT(*) AS zero_duration_non_walkover
FROM silver.atp_matches
WHERE minutes_played <= 0 AND score NOT LIKE '%W/O%';

-- Check for matches where winner and loser are the same player
SELECT COUNT(*) AS same_player_matches
FROM silver.atp_matches
WHERE winner_id = loser_id;

-- Check for invalid break points (saved > faced) — should be minimal after cleaning
SELECT COUNT(*) AS invalid_bp_winner
FROM silver.atp_matches
WHERE w_bpSaved > w_bpFaced;

SELECT COUNT(*) AS invalid_bp_loser
FROM silver.atp_matches
WHERE l_bpSaved > l_bpFaced;

-- Check tourney_date was correctly converted from NVARCHAR to DATE
SELECT COUNT(*) AS null_tourney_date
FROM silver.atp_matches
WHERE tourney_date IS NULL;

-- Check if match_id was generated for all rows
SELECT COUNT(*) AS null_match_id
FROM silver.atp_matches
WHERE match_id IS NULL;

-- Check Davis Cup consolidation — should show one record per year
SELECT tourney_id, tourney_name, COUNT(*) AS match_count
FROM silver.atp_matches
WHERE tourney_id LIKE '%-DAVIS'
GROUP BY tourney_id, tourney_name
ORDER BY tourney_id;