/* ============================================================
ATP Tour Data Warehouse
Script: Silver Layer Load Procedure — Players
Description: Cleans and loads player data from bronze to silver.
             Filters out players with no match records.

Run after: silver.load_silver_matches (required for the ID filter)
Run: EXEC silver.load_silver_players
============================================================

*/


CREATE OR ALTER PROCEDURE silver.load_silver_players AS
BEGIN 
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '==================================';
        PRINT 'Loading Silver layer: players';
        PRINT '==================================';
        PRINT '>> Truncating Table: silver.atp_players';
        TRUNCATE TABLE silver.atp_players;

        PRINT '>> Inserting Data Into: silver.atp_players';

        INSERT INTO silver.atp_players
        (id, player, atpname, birthdate, weight, height, turnedpro, birthplace, coaches, hand, backhand, ioc)
        SELECT
            id,
            TRIM(player) AS player,
            TRIM(atpname) AS atpname,
            -- birthdate fix: some birthdates were incorrectly loaded into the weight column in the source
            -- if weight looks like a date (8 digits, valid date), use it as birthdate instead
            CASE 
                WHEN LEN(weight) = 8 AND ISDATE(weight) = 1 
                THEN CAST(CAST(weight AS VARCHAR) AS DATE)
                ELSE CAST(birthdate AS DATE)
            END AS birthdate_cleaned,
            -- weight: set to NULL if value is outside a realistic range
            CASE 
                WHEN weight > 150 OR weight < 50 THEN NULL
                ELSE weight
            END AS weight_cleaned,
            -- height: set to NULL if value is outside a realistic range
            CASE 
                WHEN height < 140 OR height > 250 THEN NULL
                ELSE height
            END AS height_cleaned,
            -- turnedpro: set to NULL if date is before birthdate (data error)
            CASE 
                WHEN turnedpro < birthdate THEN NULL
                ELSE turnedpro
            END AS turnedpro,
            COALESCE(TRIM(birthplace), 'N/A') AS birthplace,
            COALESCE(TRIM(coaches), 'N/A') AS coaches,
            -- standardize hand values from single letters to full descriptions
            CASE 
                WHEN UPPER(TRIM(hand)) = 'R' THEN 'Right-Handed'
                WHEN UPPER(TRIM(hand)) = 'L' THEN 'Left-Handed'
                WHEN UPPER(TRIM(hand)) = 'A' THEN 'Ambidextrous'
                ELSE 'Unknown'
            END AS hand,
            -- standardize backhand values
            CASE 
                WHEN UPPER(TRIM(backhand)) = '1H' THEN 'One-Handed'
                WHEN UPPER(TRIM(backhand)) = '2H' THEN 'Two-Handed'
                ELSE 'Unknown'
            END AS backhand,
            COALESCE(TRIM(ioc), 'N/A') AS ioc
        FROM bronze.atp_players p
        WHERE player IS NOT NULL 
        AND TRIM(player) NOT LIKE '%Unknown%'
        -- only load players who appear in at least one match (as winner or loser)
        -- this removes ~5000 players from the source who have no match data in the 2000-2025 dataset
        AND id IN (
            SELECT winner_id FROM silver.atp_matches
            UNION
            SELECT loser_id FROM silver.atp_matches
        )


        SET @batch_end_time = GETDATE();
        PRINT '==============================';
        PRINT 'Loading Silver Player Layer is Completed';
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
