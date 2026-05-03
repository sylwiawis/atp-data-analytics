/* ============================================================
 ATP Tour Data Warehouse
 Script: Silver Layer Table Creation
 Description: Creates cleaned and standardized staging tables.
              Transformations are applied in load_silver_players.sql and load_silver_matches.sql

 Run this script before: silver.load_silver_players and silver.load_silver_matches 
 ============================================================

*/

-- ============================================================
-- Table: silver.atp_players
-- One row per player — cleaned version of bronze.atp_players
-- ============================================================


IF OBJECT_ID ('silver.atp_players' , 'U') IS NOT NULL
	DROP TABLE silver.atp_players;

CREATE TABLE silver.atp_players (
    id               NVARCHAR(10),       -- ATP player ID
    player           NVARCHAR(250),      -- player full name
    atpname          NVARCHAR(250),      -- name as used on ATP website
    birthdate        DATE,               -- converted from NVARCHAR; birthdate errors from weight column fixed in load
    weight           INT,                -- weight in kg; out-of-range values set to NULL in load
    height           INT,                -- height in cm; out-of-range values set to NULL in load
    turnedpro        DATE,               -- converted from NVARCHAR; NULL if turned pro before birthdate
    birthplace       NVARCHAR(100),      -- NULL values replaced with 'N/A' in load
    coaches          NVARCHAR(250),      -- NULL values replaced with 'N/A' in load
    hand             NVARCHAR(50),       -- standardized: Right-Handed / Left-Handed / Ambidextrous / Unknown
    backhand         NVARCHAR(20),       -- standardized: One-Handed / Two-Handed / Unknown
    ioc              NVARCHAR(10)        -- IOC country code; NULL values replaced with 'N/A' in load
);


-- ============================================================
-- Table: silver.atp_matches
-- One row per match — cleaned and enriched version of bronze.atp_matches
-- ============================================================


IF OBJECT_ID('silver.atp_matches', 'U') IS NOT NULL
    DROP TABLE silver.atp_matches;

CREATE TABLE silver.atp_matches (
    -- Generated identifiers
    match_id                VARCHAR(100),       -- surrogate match key
    tourney_year            INT,                -- extracted from tourney_id for easier filtering

    -- Tournament details
    tourney_id              NVARCHAR(100),
    tourney_name            NVARCHAR(100),      -- standardized tournament name
    tourney_name_raw        NVARCHAR(255),      -- original name from source preserved for reference
    surface                 NVARCHAR(30),       -- Hard / Clay / Grass / Carpet
    draw_size               INT,
    tourney_level           NVARCHAR(50),       -- standardized: Grand Slam / Masters / ATP 250 etc.
    indoor                  NVARCHAR(20),       -- standardized: Indoor / Outdoor
    tourney_date            DATE,               -- converted from NVARCHAR YYYYMMDD in bronze
    match_num               INT,

    -- Winner details
    winner_id               NVARCHAR(20),
    winner_seed             INT,
    winner_entry            NVARCHAR(30),       -- standardized: Wild Card / Qualifier / Lucky Loser etc.
    winner_name             NVARCHAR(100),
    winner_hand             NVARCHAR(30),       -- standardized: Right-Handed / Left-Handed / Ambidextrous
    winner_ht               INT,                -- height in cm
    winner_ioc              NVARCHAR(5),        -- IOC country code
    winner_age              DECIMAL(4,2),
    winner_rank             INT,
    winner_rank_points      INT,

    -- Loser details
    loser_id                NVARCHAR(20),
    loser_seed              INT,
    loser_entry             NVARCHAR(30),
    loser_name              NVARCHAR(100),
    loser_hand              NVARCHAR(30),
    loser_ht                INT,
    loser_ioc               NVARCHAR(5),
    loser_age               DECIMAL(4,2),
    loser_rank              INT,
    loser_rank_points       INT,

    -- Match result
    score                   NVARCHAR(50),       -- raw score string, may contain W/O or RET
    best_of                 TINYINT,            -- 3 or 5 sets
    round_full_name         NVARCHAR(50),       -- human-readable round name: First Round, Quarterfinal etc.
    round_sort_order        INT,                -- numeric order for correct sorting in Power BI
    round_name              NVARCHAR(10),       -- original short code: R128, QF, SF, F etc.
    minutes_played          INT,

    -- Winner serve statistics (w_ prefix)
    w_ace                   INT,
    w_df                    INT,                -- double faults
    w_svpt                  INT,                -- service points played
    w_1stIn                 INT,                -- first serves in
    w_1stWon                INT,                -- first serve points won
    w_2ndWon                INT,                -- second serve points won
    w_SvGms                 INT,                -- service games played
    w_bpSaved               INT,                -- break points saved
    w_bpFaced               INT,                -- break points faced

    -- Loser serve statistics (l_ prefix)
    l_ace                   INT,
    l_df                    INT,
    l_svpt                  INT,
    l_1stIn                 INT,
    l_1stWon                INT,
    l_2ndWon                INT,
    l_SvGms                 INT,
    l_bpSaved               INT,
    l_bpFaced               INT,

    
    load_timestamp          DATETIME2 DEFAULT GETDATE()  -- timestamp of when row was loaded into silver
);