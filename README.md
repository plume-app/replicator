# Replicator

This project allow you to restore the last Scalingo PostgreSQL backup in an another app.

The app need to have a PostgreSQL addon and 3 env variables set:
- `SCALINGO_CLI_TOKEN` that you can create here https://dashboard.scalingo.com/account/tokens
- `SCALINGO_ORIGINAL_POSTGRESQL_URL` is the url of the original (production) database
- `SCALINGO_POSTGRESQL_URL` is the url of the destination (replicated) database

The `/app` folder must exist. It will be used to store the dump of the original database that will be then replicated into the destination database.

You also need to follow this documentation since our app won't have any web container (any container at all actually).
https://doc.scalingo.com/platform/app/web-less-app (spoiler `scalingo --app my-app scale web:0:M`)

The empty `index.php` file is a small hack in order for the app to be deployed.
