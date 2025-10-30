#!/bin/bash


# Exit when any command fails
set -e


# Check of env vars
REQUIRED_ENV_VARS="DBT_POSTGRESQL_USER DBT_POSTGRESQL_PASSWORD DBT_POSTGRESQL_DATABASE_NAME DBT_POSTGRESQL_HOST DBT_POSTGRESQL_PORT DBT_PROFILES_DIR DBT_PROJECT_DIR"

for var in "${REQUIRED_ENV_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "$var is not set"
    exit 1
  fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - Env variables checked"


# Run dbt transformation
dbt run

echo "$(date '+%Y-%m-%d %H:%M:%S') - Full transformationprocess is complete"