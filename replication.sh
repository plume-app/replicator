#!/bin/bash


# Exit when any command fails
set -e


# Check of env vars
REQUIRED_ENV_VARS="SCALINGO_CLI_TOKEN SCALINGO_ORIGINAL_POSTGRESQL_URL SCALINGO_DESTINATION_POSTGRESQL_URL"

for var in "${REQUIRED_ENV_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "$var is not set"
    exit 1
  fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - Env variables checked"


# Install packages
install-scalingo-cli
dbclient-fetcher psql

echo "$(date '+%Y-%m-%d %H:%M:%S') - Packages installed"


# Login to Scalingo CLI
scalingo login --api-token $SCALINGO_CLI_TOKEN

echo "$(date '+%Y-%m-%d %H:%M:%S') - Logged in to Scalingo CLI"


# Dump original database with some tables excluded
DUMP_NAME=/app/partial_dump.dump

pg_dump --clean --if-exists \
  --format=c \
  --verbose \
  --dbname="${SCALINGO_ORIGINAL_POSTGRESQL_URL}" \
  --no-owner --no-privileges --no-comments \
  --exclude-schema 'information_schema' \
  --exclude-schema '^pg_*' \
  --exclude-table='public.ahoy*' \
  --exclude-table='public.solid_queue*' \
  --exclude-table='public.versions' \
  --file $DUMP_NAME

echo "$(date '+%Y-%m-%d %H:%M:%S') - Original database (partially) dumped"


# Clean public schema and set default privileges
psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<'EOSQL'
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
EOSQL

echo "$(date '+%Y-%m-%d %H:%M:%S') - Destination database : public schema dropped and recreated"

# Define roles in Bash array
ROLES="plume_app_d_8501 admin admin_patroni metabase postgresql replicator"


# Set schema usage, default privileges, and grants for future objects
for role in $ROLES; do
  psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<EOSQL
    GRANT USAGE ON SCHEMA public TO $role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $role;
EOSQL
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - All privileges granted before restore"

# Restore database into destination database
pg_restore --section=pre-data \
  --clean --if-exists \
  --no-owner --no-privileges \
  --verbose \
  --dbname=$SCALINGO_DESTINATION_POSTGRESQL_URL \
  $DUMP_NAME

pg_restore --section=data \
  --no-owner --no-privileges \
  --disable-triggers \
  --verbose \
  --dbname=$SCALINGO_DESTINATION_POSTGRESQL_URL \
  $DUMP_NAME

pg_restore --section=post-data \
  --no-owner --no-privileges \
  --verbose \
  --dbname=$SCALINGO_DESTINATION_POSTGRESQL_URL \
  $DUMP_NAME


echo "$(date '+%Y-%m-%d %H:%M:%S') - Restore is complete"

# Grant privileges on all restored tables
for role in $ROLES; do
  psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<EOSQL
    GRANT ALL ON ALL TABLES IN SCHEMA public TO $role;
EOSQL
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - All privileges granted after restore"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Full replication process is complete"