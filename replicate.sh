#!/bin/bash

# Exit when any command fails
set -e

if [ -z "$SOURCE_APP" ]
then
  echo "SOURCE_APP is not set"
  exit 1
fi

if [ -z "$SCALINGO_CLI_TOKEN" ]
then
  echo "SCALINGO_CLI_TOKEN is not set"
  exit 1
fi

if [ -z "$SCALINGO_POSTGRESQL_URL" ]
then
  echo "SCALINGO_POSTGRESQL_URL is not set"
  exit 1
fi

install-scalingo-cli
dbclient-fetcher psql

scalingo login --api-token $SCALINGO_CLI_TOKEN

ADDON_ID=`scalingo --app $SOURCE_APP addons | grep postgresql | awk -F ' | ' '{print $4}'`

ARCHIVE_NAME=backup.tar.gz

scalingo --app $SOURCE_APP --addon $ADDON_ID backups-download --output $ARCHIVE_NAME

BACKUP_NAME=`tar -tf $ARCHIVE_NAME | tail -n 1`

tar -C /app -xvf $ARCHIVE_NAME


pg_restore --section=pre-data \
  --clean --if-exists \
  --no-owner --no-privileges \
  --verbose \
  --dbname=$SCALINGO_POSTGRESQL_URL \
  /app$BACKUP_NAME


pg_restore --section=data \
  --no-owner --no-privileges \
  --disable-triggers \
  --jobs=8 \
  --verbose \
  --dbname=$SCALINGO_POSTGRESQL_URL \
  /app$BACKUP_NAME


pg_restore --section=post-data \
  --no-owner --no-privileges \
  --verbose \
  --dbname=$SCALINGO_POSTGRESQL_URL \
  /app$BACKUP_NAME

