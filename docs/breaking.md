# Breaking Changes

## Oct 17, 2019
- `start_time` and `stop_time` parameters have been renamed to `started_at` and `stopped_at` to be consistent with other time-based information fields like `created_at` and `queued_at`. This change affects the [Get a Workflow's Job](https://circleci.com/docs/api/v2/#get-a-workflow-39-s-jobs) endpoint 
- Cancelling a job is no longer a `POST` to `/project/:roject-slug/job/:jobnum`. The job cancellation action is now a `POST` to `/project/:project-slug/job/:jobnum/cancel`
