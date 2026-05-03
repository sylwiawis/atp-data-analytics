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
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
      BEGIN TRY

      SET @batch_start_time = GETDATE();
        PRINT '==================================';
        PRINT 'Loading Bronze layer: players';
        PRINT '==================================';

        SET @start_time= GETDATE();
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


        SET @batch_start_time = GETDATE();
        PRINT '==================================';
        PRINT 'Loading Bronze layer: matches';
        PRINT '==================================';

        SET @start_time= GETDATE();
        PRINT '>> Truncating Table: bronze.atp_matches';
        TRUNCATE TABLE bronze.atp_matches;

        -- Match data is split into one CSV file per year (2000-2025)
        -- Each file is appended to the same table using INSERT (no TRUNCATE between years)
        PRINT '==================================';
        PRINT 'Loading year 2000';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2000.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();
        PRINT '==================================';
        PRINT 'Loading year 2001';


        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2001.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();
        PRINT '==================================';
        PRINT 'Loading year 2002';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2002.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2003';
 

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2003.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2004';


        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2004.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2005';


        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2005.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2006';



        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2006.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2007';


        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2007.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2008';

            
        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2008.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2009';


        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2009.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2010';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2010.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2011';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2011.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2012';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2012.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2013';

            
        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2013.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2014';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2014.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2015';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2015.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2016';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2016.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2017';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2017.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2018';
            
        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2018.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2019';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2019.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2020';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2020.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2021';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2021.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2022';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2022.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2023';

            
        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2023.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2024';

        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2024.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

        SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

        SET @start_time= GETDATE();

        PRINT '==================================';
        PRINT 'Loading year 2025';
    
        BULK INSERT bronze.atp_matches
        FROM 'C:\Users\Sylwia\Desktop\atp_database\atp_2000_2025data\2025.csv'
        WITH (
            FORMAT = 'csv',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            KEEPNULLS,
            TABLOCK)

             SET @end_time= GETDATE();
            PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT'>> ----------';

    
        SET @batch_end_time = GETDATE();
        PRINT '==============================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT ' - Total Load Duration: ' +  CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
          PRINT '==============================';
    END TRY
    BEGIN CATCH
        PRINT '==============================='
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE ();
        PRINT 'Error Message: ' + CAST(ERROR_NUMBER () AS NVARCHAR);
        PRINT '==============================='
    END CATCH
END