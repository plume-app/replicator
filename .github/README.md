# GitHub Action to trigger database replication on Scalingo

## _Main objective_

Scalingo does NOT allow more than 15-min containers for scheduled task : https://doc.scalingo.com/platform/app/task-scheduling/scalingo-scheduler.

But non-scheduled containers started with command such as `scalingo --app some-app run 'some command'` can live longer.

Hence, we use [GitHub Actions](https://github.com/features/actions) to execute (and schedule) this command.

## _Env_

- `SCALINGO_CLI_TOKEN` need to be set as repository secret in GitHub.
  

## _Output_

Git Hub Actions allow to keep tracks of logs. After a run completes, a `replication-log.zip` with the logs of the run can be found in the Artifacts section in the workflow run page.

## _Usage_

**Free with limits** : https://docs.github.com/en/billing/concepts/product-billing/github-actions#free-use-of-github-actions