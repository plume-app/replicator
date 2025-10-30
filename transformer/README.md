# Transformer

Transformer project with `dbt` Python package : https://pypi.org/project/dbt/.

It needs the following env vars (mainly used in the `transformer/profiles.yml` file) :
- `DBT_POSTGRESQL_USER` : username of the replicated database
- `DBT_POSTGRESQL_PASSWORD` : password for the above username
- `DBT_POSTGRESQL_DATABASE_NAME` : name of the replicate database
- `DBT_POSTGRESQL_HOST` : host of the replicate database
- `DBT_POSTGRESQL_PORT` : port of the replicate database
- `dbt` also needs two additionals env vars that will be used when `dbt` is used (as in `dbt run`) :
  - `DBT_PROFILES_DIR` : location of the `transformer/profiles.yml` file
  - `DBT_PROJECT_DIR` : location of the `transformer/dbt_project.yml` file

As recommended by Scalingo, it uses `pipenv` (https://pypi.org/project/pipenv/) to set up the Python environnement as specified by the `Pipfile` and `Pipfile.lock` files.
- note : The `Pipfile.lock` was simply generated once using the `pipenv lock` command.

### Usage

- Run `dbt debut` to check if everything is set correctly.
- Run `dbt run` to run all available models in the `transformer/models` folder.