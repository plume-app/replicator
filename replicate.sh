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

if [ -z "$SCALINGO_POSTGRESQL_URL" ]
then
  echo "SCALINGO_POSTGRESQL_URL is not set"
  exit 1
fi


# Install packages
install-scalingo-cli
dbclient-fetcher psql


# Login to scaling cli
scalingo login --api-token $SCALINGO_CLI_TOKEN


DUMP_NAME=/app/partial_dump.dump

# Dump original database with some tables excluded
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


# Restore database into destination database
pg_restore --section=pre-data \
  --clean --if-exists \
  --no-owner --no-privileges \
  --verbose \
  --dbname=$SCALINGO_POSTGRESQL_URL \
  $DUMP_NAME


pg_restore --section=data \
  --no-owner --no-privileges \
  --disable-triggers \
  --verbose \
  --dbname=$SCALINGO_POSTGRESQL_URL \
  $DUMP_NAME


pg_restore --section=post-data \
  --no-owner --no-privileges \
  --verbose \
  --dbname=$SCALINGO_POSTGRESQL_URL \
  $DUMP_NAME

echo "$(date '+%Y-%m-%d %H:%M:%S') - Process is complete"