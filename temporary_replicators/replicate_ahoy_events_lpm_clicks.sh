#!/bin/bash


# Exit when any command fails
set -e


# Check of env vars
if [ -z "$SCALINGO_CLI_TOKEN" ]
then
  echo "SCALINGO_CLI_TOKEN is not set"
  exit 1
fi

if [ -z "$SCALINGO_ORIGINAL_POSTGRESQL_URL" ]
then
  echo "SCALINGO_ORIGINAL_POSTGRESQL_URL is not set"
  exit 1
fi

if [ -z "$SCALINGO_DESTINATION_POSTGRESQL_URL" ]
then
  echo "SCALINGO_DESTINATION_POSTGRESQL_URL is not set"
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Env variables checked"

# Install packages
install-scalingo-cli
dbclient-fetcher psql

echo "$(date '+%Y-%m-%d %H:%M:%S') - Packages installed"


# Login to Scalingo CLI
scalingo login --api-token $SCALINGO_CLI_TOKEN

echo "$(date '+%Y-%m-%d %H:%M:%S') - Logged in to Scalingo CLI"


# Export query result from original database into a CSV file
CSV_OUTPUT_FILE="/app/ahoy_lpm_clicks.csv"

psql "$SCALINGO_ORIGINAL_POSTGRESQL_URL" > "$CSV_OUTPUT_FILE" 2>/dev/null <<EOSQL
\set ON_ERROR_STOP on
COPY (
  SELECT *
  FROM public.ahoy_events
  WHERE name = '\$click'
    AND time >= '2025-09-01'
    AND properties ? 'href'
    AND properties->>'href' LIKE '%https://fr.plume-app.co/espace-enseignant/concours/les-petits-molieres-2025%'
) TO STDOUT WITH CSV HEADER;
EOSQL

echo "$(date '+%Y-%m-%d %H:%M:%S') - Query on original database exported to CSV file"


# Create 'analytics' schema in destination database if not exists
psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<EOSQL
CREATE SCHEMA IF NOT EXISTS analytics;
EOSQL

echo "$(date '+%Y-%m-%d %H:%M:%S') - Schema 'analytics' ensured in destination database"


# Create empty table in destination database (matching CSV columns)
psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<EOSQL
CREATE TABLE IF NOT EXISTS analytics.ahoy_lpm_clicks (
  id bigint, 
  visit_id bigint, 
  user_id bigint, 
  name character varying, 
  properties jsonb, 
  time timestamp without time zone, 
  kid_id bigint
);
EOSQL

echo "$(date '+%Y-%m-%d %H:%M:%S') - Table 'analytics.ahoy_lpm_clicks' created in destination database"


# Load CSV into destination table
psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<EOSQL
BEGIN;
\copy analytics.ahoy_lpm_clicks FROM '$CSV_OUTPUT_FILE' WITH CSV HEADER;
COMMIT;
EOSQL

echo "$(date '+%Y-%m-%d %H:%M:%S') - Data loaded into analytics.ahoy_lpm_clicks"


echo "$(date '+%Y-%m-%d %H:%M:%S') - Full process is complete"
