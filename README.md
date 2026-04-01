# Weather dbt Pipeline

End-to-end weather data pipeline ingesting hourly meteorological data for 5 global cities using Python, dbt, Snowflake, and Airflow.

## Architecture
```
Open-Meteo API
     ↓
Python Ingestion (tenacity retry logic)
     ↓
Snowflake RAW schema
     ↓
dbt Staging → dbt Marts → dbt Vault
     ↓
Airflow DAG (hourly orchestration)
```

## Stack

- Python 3.11
- Snowflake
- dbt 1.11 + dbt_utils
- Apache Airflow
- GitHub Actions CI/CD

## Cities

Prague, London, New York, Tokyo, Sydney

## Project Structure
```
weather-dbt-pipeline/
├── airflow/dags/        # Airflow DAG
├── dbt_weather/
│   ├── models/
│   │   ├── staging/     # stg_weather, stg_cities
│   │   ├── marts/       # mart_weather_current, mart_weather_trends, mart_city_rankings, mart_weather_summary
│   │   └── vault/       # hub_city, hub_weather_condition, link_city_condition, sat_weather_measurements
│   ├── seeds/           # cities.csv, weather_codes.csv
│   ├── snapshots/       # SCD Type 2 on weather_codes
│   └── tests/           # singular tests
├── ingestion/           # Python EL pipeline
└── snowflake/           # setup.sql
```

## Setup

### 1. Clone repo
```bash
git clone https://github.com/SobanDEprep/weather-dbt-pipeline.git
cd weather-dbt-pipeline
```

### 2. Install dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure environment
```bash
cp .env.example .env
# fill in your Snowflake credentials
```

### 4. Snowflake setup

Run `snowflake/setup.sql` in your Snowflake worksheet.

### 5. Run ingestion
```bash
cd ingestion
python ingest.py  # auto-detects first run and backfills 7 days
```

### 6. Run dbt
```bash
cd dbt_weather
dbt deps
dbt seed
dbt run
dbt test
```

## dbt Features

- Incremental models with `unique_key`
- Window functions — `LAG()`, `AVG() OVER()`, `DENSE_RANK()`
- Data Vault — Hub, Link, Satellite
- SCD Type 2 snapshots
- `dbt_utils` — `generate_surrogate_key()`
- `dbt source freshness`
- Generic + singular tests
- CI/CD via GitHub Actions

## Snowflake Features

- Role-based access control (WEATHER_ADMIN, WEATHER_DBT, WEATHER_ANALYST)
- Zero-Copy Clone (WEATHER_DB_DEV)
- Streams + Tasks
- Cortex AI COMPLETE()

## CI/CD

GitHub Actions runs on every push to main:
`dbt deps` → `dbt seed` → `dbt run` → `dbt test`