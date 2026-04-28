# atp-data-analysis

# ATP Tour Analytics | 2000–2025

An end-to-end data analytics project built on ATP Tour match data from 2000 to 2025. The dashboard was designed from the perspective of a **tennis coaching staff or player agent** — providing tools to analyze player performance, track career trends, compare opponents head-to-head, and identify patterns across surfaces and playing styles.

---

## Data Source

Raw data sourced from [TML Database](https://github.com/Tennismylife/TML-Database) — a complete, live-updated database of ATP tournaments and matches, originally inspired by Jeff Sackmann's tennis_atp repository. Key advantages of this source include fully integrated missing data, use of official ATP player IDs, and daily updates based on ATP official results and corrections.

---

## Project Architecture

The project follows a **medallion architecture** with three layers:

```
Raw CSV files
      │
      ▼
  📁 Bronze        ← raw data, no transformations
      │
      ▼
  📁 Silver        ← cleaning, standardization, filtering
      │
      ▼
  📁 Gold          ← star schema, ready for Power BI
```

### Bronze
Raw data loaded as-is from CSV files into SQL Server. No transformations applied — this layer preserves the original source data.

### Silver
Data cleaning and standardization layer. Key transformations include:
- Trimming whitespace and standardizing text fields
- Fixing data entry errors (e.g. birthdates loaded into weight column)
- Handling nulls with `COALESCE` and setting valid value ranges for height and weight
- Standardizing categorical fields (hand, backhand, surface) using `CASE WHEN`
- Filtering out players with no match records

### Gold
Business-ready layer structured as a **star schema** for efficient querying in Power BI:

```
                    ┌─────────────────┐
                    │  dim_players    │
                    └────────┬────────┘
                             │
┌──────────────┐    ┌────────▼────────┐    ┌──────────────────────────┐
│dim_tournaments├───►   fact_match    ◄────┤ fact_match_player_stats  │
└──────────────┘    └─────────────────┘    └──────────────────────────┘
```

| Table | Description |
|-------|-------------|
| `dim_players` | Player profiles — name, nationality, height, weight, hand, backhand, birthdate |
| `dim_tournaments` | Tournament details — name, surface, level (Grand Slam, Masters, etc.), indoor flag |
| `fact_match` | One row per match — winner/loser IDs, score, duration, round, upset flag |
| `fact_match_player_stats` | One row per player per match — ranking, rank points, serve stats, break points |

Additional views built on top of gold:

| View | Description |
|------|-------------|
| `win_streak` | Consecutive win/loss streaks per player |
| `player_ranking_trend` | Ranking points per match with 10 and 20-match moving averages |
| `player_aces_trend` | Aces per match trend over career |

---

## Technologies

- **SQL Server** — data storage, cleaning, and modeling
- **Power BI Desktop** — dashboard and visualizations
- **DAX** — measures and calculated columns in Power BI

---

## Key SQL Techniques

- **CTEs** — used throughout silver and gold layers for readable, modular queries
- **Window functions** — `ROW_NUMBER()` for streak detection, `LAG()` for year-over-year ranking comparison, `AVG() OVER()` for moving averages, `LAST_VALUE() IGNORE NULLS` for forward-filling missing ranking data
- **`CASE WHEN`** — data standardization, bucketing (duration categories, upset categories, height groups)
- **`UNION ALL`** — combining winner and loser perspectives into a single player-level stats table
- **`CAST`, `TRIM`, `COALESCE`** — data type corrections and null handling in silver layer
- **Aggregate functions** — `MIN`, `MAX`, `COUNT`, `SUM` across multiple grouping levels

---

## Dashboard Overview

### Player Profile
![Player Profile](screenshots/player_profile.png)

A detailed view of an individual player's career, filterable by name. Includes:
- Career high rank, age, weight, height, hand, backhand, nationality, turned pro date
- Match results — won/lost ratio and effectiveness by match duration
- Titles won by tournament type with drill-down to specific tournament names
- Results by surface
- Serve statistics — aces per match, double faults, ace-to-DF ratio, 1st serve %, 1st serve points won %, 2nd serve points won %
- Career Ranking Points Trend with 10-match and 20-match moving averages
- Head-to-head navigation

### Top Players
![Top Players](screenshots/top_players.png)

Comparative analysis of the best players in the dataset:
- Total titles by tournament type with drill-down
- Age at first World No. 1
- Longest winning streak
- Top servers — aces, double faults, ace-to-DF ratio
- Final win rate and effectiveness by surface
- Top ranking by year and win rate by surface for selected year

### Insights
![Insights](screenshots/insights.png)

Exploratory analysis and pattern discovery:
- Upset rate by round
- Win rate by age (filtered to players with 100+ matches)
- Average and longest match duration
- ATP players by country with highest-ever ranking on hover
- Average aces per match by height group
- Win rate by playing style — hand and backhand type

### Head to Head
![Head to Head](screenshots/head_to_head.png)

Direct comparison between two selected players — overall H2H record, results by surface and by round.

---

## How to Run

Run scripts in the following order:

```
1. sql/bronze/        → create tables and load raw CSV data
2. sql/silver/        → run stored procedures for players and matches
3. sql/gold/          → run dimension views first, then fact views
4. sql/gold/views/    → run additional analytical views
```

Then open `atp_tour_analytics.pbix` in Power BI Desktop and refresh the data source connection.

---

## Notes

- Walkovers (`W/O`) and retired matches (`RET`) are flagged in `match_status` and excluded from duration and streak analysis where appropriate
- Ranking data is only available at match level (not weekly), which creates gaps for players who did not compete in a given month — moving averages are used to smooth trends
- Win rate by age analysis is subject to **survivorship bias** at older ages — only elite players continue competing past 33, which inflates win rates for those age groups