/*
============================================================
ATP Tour Data Warehouse
Script: Silver Layer Load Procedure — Matches
Description: Cleans, deduplicates and loads match data from bronze to silver.

Key transformations:
  - Deduplication of matches (Davis Cup duplicates, round number conflicts)
  - Generated match_id and tourney_year
  - Davis Cup consolidation into single tournament ID
  - Standardized categorical values (hand, entry, surface, tourney_level, indoor)
  - Round full name and sort order added via inline mapping table
  - Manual ID and IOC fix for Harshana Godamanna
  - Exclusion of duplicate player record (Marc-Andrea Huesler)

Run after: bronze.atp_matches must be populated
Run: EXEC silver.load_silver
=============================================================

*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '==================================';
        PRINT 'Loading Silver layer: matches';
        PRINT '==================================';

        PRINT '>> Truncating Table: silver.atp_matches';
        TRUNCATE TABLE silver.atp_matches;

        PRINT '>> Inserting Data Into: silver.atp_matches';

        -- Step 1: Deduplicate bronze matches
        -- Davis Cup matches had duplicate records with different tourney_names and IDs
        -- for the same physical match — deduplicated by grouping on year+DAVIS key
        -- Other duplicates differed only in round number — resolved by preferring
        -- higher rounds (F > SF > QF), then matches with duration data, then by match_num
        WITH deduplicated_matches AS (
            SELECT * FROM (
                SELECT *, 
                    ROW_NUMBER() OVER (PARTITION BY 
                            CASE WHEN tourney_name LIKE 'Davis Cup%' THEN CAST(LEFT(tourney_date, 4) AS VARCHAR) + '-DAVIS'
                                ELSE tourney_id
                            END, 
                            winner_id, loser_id, score
                        ORDER BY 
                            CASE 
                                WHEN round_name = 'F'  THEN 1
                                WHEN round_name = 'SF' THEN 2
                                WHEN round_name = 'QF' THEN 3
                                WHEN round_name = 'RR' THEN 4 
                                ELSE 5
                            END ASC,
                            CASE WHEN minutes_played IS NOT NULL THEN 0 ELSE 1 END,
                            match_num ASC
                    ) AS flag
                FROM bronze.atp_matches
            ) t 
            WHERE flag = 1
        )

        INSERT INTO silver.atp_matches(
            match_id, tourney_year, tourney_id, tourney_name, tourney_name_raw,
            surface, draw_size, tourney_level, indoor, tourney_date, match_num,
            winner_id, winner_seed, winner_entry, winner_name, winner_hand,
            winner_ht, winner_ioc, winner_age, winner_rank, winner_rank_points,
            loser_id, loser_seed, loser_entry, loser_name, loser_hand,
            loser_ht, loser_ioc, loser_age, loser_rank, loser_rank_points,
            score, best_of, round_full_name, round_sort_order, round_name, minutes_played,
            w_ace, w_df, w_svpt, w_1stIn, w_1stWon, w_2ndWon, w_SvGms, w_bpSaved, w_bpFaced,
            l_ace, l_df, l_svpt, l_1stIn, l_1stWon, l_2ndWon, l_SvGms, l_bpSaved, l_bpFaced,
            load_timestamp
        )

        SELECT 
            -- generated match_id: year prefix + sequential number
            'M-' + CAST(LEFT(b.tourney_date, 4) AS VARCHAR) + '-' + 
                CAST(ROW_NUMBER() OVER (ORDER BY b.tourney_date, b.tourney_id, b.winner_id) AS VARCHAR) AS match_id,
            CAST(LEFT(b.tourney_date, 4) AS INT) AS tourney_year,

            -- Davis Cup: consolidate all Davis Cup matches into a single tourney_id per year
            -- to avoid thousands of separate tournament records (one per tie)
            CASE 
                WHEN b.tourney_name LIKE 'Davis Cup%' 
                THEN CAST(LEFT(b.tourney_date, 4) AS VARCHAR) + '-DAVIS'
                ELSE b.tourney_id
            END AS tourney_id,
            CASE 
                WHEN b.tourney_name LIKE 'Davis Cup%' THEN 'Davis Cup'
                ELSE b.tourney_name 
            END AS tourney_name,
            b.tourney_name AS tourney_name_raw,   -- preserve original name for reference

            COALESCE(b.surface, 'Unknown') AS surface,
            b.draw_size,

            -- standardize tourney_level codes to full descriptions
            CASE 
                WHEN b.tourney_level = 'G'   THEN 'Grand Slam'
                WHEN b.tourney_level = 'M'   THEN 'ATP Masters 1000'
                WHEN b.tourney_level = '500' THEN 'ATP 500'
                WHEN b.tourney_level = '250' THEN 'ATP 250'
                WHEN b.tourney_level = 'A'   THEN 'Other/International'
                WHEN b.tourney_level = 'F'   THEN 'Tour Finals'
                WHEN b.tourney_level = 'D'   THEN 'Davis Cup'
                WHEN b.tourney_level = 'O'   THEN 'Olympics'
                ELSE 'Unknown'
            END AS tourney_level,

            CASE 
                WHEN UPPER(b.indoor) = 'O' THEN 'Outdoor'
                WHEN UPPER(b.indoor) = 'I' THEN 'Indoor'
                ELSE 'Unknown'
            END AS indoor,

            CAST(b.tourney_date AS DATE) AS tourney_date,
            b.match_num,

            -- manual ID fix: Harshana Godamanna had two different IDs in the source
            CASE 
                WHEN b.winner_name = 'Harshana Godamanna' THEN '104631'
                ELSE b.winner_id
            END AS winner_id,
            b.winner_seed,

            -- standardize entry codes to full descriptions
            CASE 
                WHEN b.winner_entry = 'WC'  THEN 'Wild Card'
                WHEN b.winner_entry = 'Q'   THEN 'Qualifier'
                WHEN b.winner_entry = 'LL'  THEN 'Lucky Loser'
                WHEN b.winner_entry = 'PR'  THEN 'Protected Ranking'
                WHEN b.winner_entry = 'SE'  THEN 'Special Exempt'
                WHEN b.winner_entry = 'ALT' THEN 'Alternate'
                WHEN b.winner_entry = 'ITF' THEN 'ITF Entry'
                ELSE 'Standard'
            END AS winner_entry,
            TRIM(b.winner_name) AS winner_name,
            CASE 
                WHEN UPPER(TRIM(b.winner_hand)) = 'R' THEN 'Right-Handed'
                WHEN UPPER(TRIM(b.winner_hand)) = 'L' THEN 'Left-Handed'
                WHEN UPPER(TRIM(b.winner_hand)) = 'A' THEN 'Ambidextrous'
                ELSE 'Unknown'
            END AS winner_hand,
            b.winner_ht,

            -- manual IOC fix for Harshana Godamanna
            CASE 
                WHEN TRIM(b.winner_name) = 'Harshana Godamanna' THEN 'SRI'
                ELSE COALESCE(b.winner_ioc, 'N/A') 
            END AS winner_ioc,
            b.winner_age,
            b.winner_rank,
            b.winner_rank_points,
            b.loser_id,
            b.loser_seed,
            CASE 
                WHEN b.loser_entry = 'WC'  THEN 'Wild Card'
                WHEN b.loser_entry = 'Q'   THEN 'Qualifier'
                WHEN b.loser_entry = 'LL'  THEN 'Lucky Loser'
                WHEN b.loser_entry = 'PR'  THEN 'Protected Ranking'
                WHEN b.loser_entry = 'SE'  THEN 'Special Exempt'
                WHEN b.loser_entry = 'ALT' THEN 'Alternate'
                WHEN b.loser_entry = 'ITF' THEN 'ITF Entry'
                ELSE 'Standard'
            END AS loser_entry,
            TRIM(b.loser_name) AS loser_name,
            CASE 
                WHEN UPPER(TRIM(b.loser_hand)) = 'R' THEN 'Right-Handed'
                WHEN UPPER(TRIM(b.loser_hand)) = 'L' THEN 'Left-Handed'
                WHEN UPPER(TRIM(b.loser_hand)) = 'A' THEN 'Ambidextrous'
                ELSE 'Unknown'
            END AS loser_hand,
            b.loser_ht,
            COALESCE(b.loser_ioc, 'N/A') AS loser_ioc,
            b.loser_age,
            b.loser_rank,
            b.loser_rank_points,
            b.score,
            b.best_of,

            -- round names and sort order joined from inline mapping table
            map.round_full_name,
            map.round_sort_order,
            b.round_name,
            b.minutes_played,
            b.w_ace, b.w_df, b.w_svpt, b.w_1stIn, b.w_1stWon, b.w_2ndWon,
            b.w_SvGms, 
            CASE WHEN b.w_bpSaved > b.w_bpFaced THEN NULL ELSE b.w_bpSaved END AS w_bpSaved,
            b.w_bpFaced,
            b.l_ace, b.l_df, b.l_svpt, b.l_1stIn, b.l_1stWon, b.l_2ndWon,
            b.l_SvGms, 
            CASE WHEN b.l_bpSaved > b.l_bpFaced THEN NULL ELSE b.l_bpSaved END AS l_bpSaved, 
            b.l_bpFaced,
            GETDATE() AS load_timestamp

        FROM deduplicated_matches b
        LEFT JOIN (
            VALUES 
                ('F',       'Final',          1),
                ('SF',      'Semi-Finals',    2),
                ('3rd/4th', 'Bronze Medal',   3),
                ('BR',      'Bronze Medal',   3),
                ('QF',      'Quarter-Finals', 4),
                ('R16',     'Round of 16',    5),
                ('R32',     'Round of 32',    6),
                ('R64',     'Round of 64',    7),
                ('R128',    'Round of 128',   8),
                ('RR',      'Round Robin',    9)
        ) AS map(round_short, round_full_name, round_sort_order) 
        ON b.round_name = map.round_short

        -- exclude duplicate player record with incorrect ID
        WHERE NOT (winner_id = 'MH30' AND winner_name = 'Marc-Andrea Huesler')

        SET @batch_end_time = GETDATE();
        PRINT '==============================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==============================';

    END TRY
    BEGIN CATCH
        PRINT '==============================='
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '==============================='
    END CATCH
END