/* ============================================================
ATP Tour Data Warehouse
Script: Bronze Layer Table Creation
Description: Creates raw staging tables for player and match data.
             Tables mirror the source CSV structure exactly -
             no transformations or constraints applied at this stage.
             Existing tables are dropped and recreated on each run.
Source: TML Database (https://github.com/Tennismylife/TML-Database)

Run this script before: bronze.load_bronze
============================================================
*/

-- ============================================================
-- Table: bronze.atp_players
-- One row per player
-- ============================================================


IF OBJECT_ID('bronze.atp_players', 'U') IS NOT NULL
    DROP TABLE bronze.atp_players;

CREATE TABLE bronze.atp_players (
    id               NVARCHAR(10),       
    player           NVARCHAR(250),      
    atpname          NVARCHAR(250),     
    birthdate        NVARCHAR(50),       -- stored as NVARCHAR due to data quality issues in source
    weight           INT,                
    height           INT,                
    turnedpro        NVARCHAR(50),       
    birthplace       NVARCHAR(100),
    coaches          NVARCHAR(250),
    hand             NVARCHAR(100),      -- playing hand: R / L / A (ambidextrous)
    backhand         NVARCHAR(10),       -- backhand type: 1H / 2H
    ioc              NVARCHAR(10)        -- IOC country code (3-letter)
);


-- ============================================================
-- Table: bronze.atp_matches
-- One row per match — contains winner, loser, tournament,
-- and match statistics in a single denormalized row
-- ============================================================

IF OBJECT_ID('bronze.atp_matches', 'U') IS NOT NULL
    DROP TABLE bronze.atp_matches;

CREATE TABLE bronze.atp_matches (
    -- Tournament details
    tourney_id              NVARCHAR(100),  
    tourney_name            NVARCHAR(100),
    surface                 NVARCHAR(20),   
    draw_size               INT,            
    tourney_level           NVARCHAR(10),   
    indoor                  NVARCHAR(5),    
    tourney_date            NVARCHAR(10),   -- tournament start date (YYYYMMDD)
    match_num               INT,            

    -- Winner details
    winner_id               NVARCHAR(20),
    winner_seed             INT,
    winner_entry            NVARCHAR(10),   -- entry type: WC, Q, LL, etc.
    winner_name             NVARCHAR(100),
    winner_hand             NVARCHAR(5),
    winner_ht               INT,            -- height in cm
    winner_ioc              NVARCHAR(5),
    winner_age              DECIMAL(4,2),
    winner_rank             INT,
    winner_rank_points      INT,

    -- Loser details
    loser_id                NVARCHAR(20),
    loser_seed              INT,
    loser_entry             NVARCHAR(10),
    loser_name              NVARCHAR(100),
    loser_hand              NVARCHAR(5),
    loser_ht                INT,
    loser_ioc               NVARCHAR(5),
    loser_age               DECIMAL(4,2),
    loser_rank              INT,
    loser_rank_points       INT,

    -- Match result
    score                   NVARCHAR(50),   
    best_of                 TINYINT,        -- 3 or 5 sets
    round_name              NVARCHAR(10),   
    minutes_played          INT,

    -- Winner serve statistics (w_ prefix)
    w_ace                   INT,
    w_df                    INT,            -- double faults
    w_svpt                  INT,            -- service points played
    w_1stIn                 INT,            -- first serves in
    w_1stWon                INT,            -- first serve points won
    w_2ndWon                INT,            -- second serve points won
    w_SvGms                 INT,            -- service games played
    w_bpSaved               INT,            -- break points saved
    w_bpFaced               INT,            -- break points faced

    -- Loser serve statistics (l_ prefix)
    l_ace                   INT,
    l_df                    INT,
    l_svpt                  INT,
    l_1stIn                 INT,
    l_1stWon                INT,
    l_2ndWon                INT,
    l_SvGms                 INT,
    l_bpSaved               INT,
    l_bpFaced               INT
);