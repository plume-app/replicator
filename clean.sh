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


# Install packages
install-scalingo-cli
dbclient-fetcher psql


# Login to scaling cli
scalingo login --api-token $SCALINGO_CLI_TOKEN


# Clean public schema of destination database
psql "$SCALINGO_DESTINATION_POSTGRESQL_URL" <<'EOSQL'
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO plume_app_d_8501;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin_patroni;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO metabase;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgresql;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO replicator;
EOSQL


echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleaning process is complete"