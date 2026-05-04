/* 
============================================================
ATP Tour Data Warehouse
Script: Bronze Layer Load Procedure
Description: Loads raw data from CSV files into bronze schema
              without any transformations. Data is loaded as-is
              to preserve the original source.
 
Source: TML Database (https://github.com/Tennismylife/TML-Database)
 
Tables loaded:
  - bronze.atp_players  (player profiles)
  - bronze.atp_matches  (match results 2000-2025, one file per year)
 
Note: File paths are set to local machine. Update paths before running.
Run: EXEC bronze.load_bronze
============================================================
*/
 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @SQL NVARCHAR(MAX),
        @file_path NVARCHAR(500),
        @YEAR INT,
        @start_year INT,
        @end_year INT;
 
    BEGIN TRY
 
        SET @batch_start_time = GETDATE();
 
        PRINT '==================================';
        PRINT 'Loading Bronze layer: players';
        PRINT '==================================';
 
        SET @start_time = GETDATE();
 
        PRINT '>> Truncating Table: bronze.atp_players';
        TRUNCATE TABLE bronze.atp_players;
 
        -- Loading player profiles from a single CSV file
        BULK INSERT bronze.atp_players
        FROM 'C:\Users\Sylwia\Desktop\atp_database\DANE\ATP_Database.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,               -- skip header row
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,                  -- preserve NULL values from source
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

 
        PRINT '==================================';
        PRINT 'Loading Bronze layer: matches';
        PRINT '==================================';
 
        PRINT '>> Truncating Table: bronze.atp_matches';
        TRUNCATE TABLE bronze.atp_matches;
 
        SET @start_year = 2000;
        SET @end_year = 2025;
        SET @YEAR = @start_year;
 
        WHILE @YEAR <= @end_year
        BEGIN
            PRINT '==================================';
            PRINT 'Loading year ' + CAST(@YEAR AS NVARCHAR(4));
 
            SET @start_time = GETDATE();
 
            SET @file_path = 
                N'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\'
                + CAST(@year AS NVARCHAR(4))
                + N'.csv';
 
            SET @sql = N'
                BULK INSERT bronze.atp_matches
                FROM ''' + @file_path + N'''
                WITH (
                    FORMAT = ''csv'',
                    FIRSTROW = 2,
                    FIELDTERMINATOR = '','',
                    ROWTERMINATOR = ''0x0a'',
                    KEEPNULLS,
                    TABLOCK
                );
            ';
 
            EXEC sp_executesql @sql;
 
            SET @end_time = GETDATE();
 
            PRINT '>> LOAD Duration: ' 
                + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
                + ' seconds';
 
            PRINT '>> ----------';
 
            SET @YEAR = @YEAR + 1;
        END;
 
 
        SET @batch_end_time = GETDATE();
 
        PRINT '==============================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT ' - Total Load Duration: ' 
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
            + ' seconds';
        PRINT '==============================';
 
    END TRY
 
    BEGIN CATCH
        PRINT '===============================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '===============================';
    END CATCH
END;
