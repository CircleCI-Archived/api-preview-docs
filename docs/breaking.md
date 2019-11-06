# Breaking Changes

## Oct 17, 2019

- `start_time` and `stop_time` parameters have been renamed to `started_at` and `stopped_at` to be consistent with other time-based information fields like `created_at` and `queued_at`. This change affects the [Get a Workflow's Job](https://circleci.com/docs/api/v2/#get-a-workflow-39-s-jobs) endpoint
- Cancelling a job is no longer a `POST` to `/project/:project-slug/job/:jobnum`. The job cancellation action is now a `POST` to `/project/:project-slug/job/:jobnum/cancel`

# Proposed Breaking Changes

## Log

### Nov 5, 2019

- Route changes will not be pluralized, instead they will be all singular
- `workflows` will be removed from the [Get a pipeline](https://circleci.com/docs/api/v2/#get-a-pipeline) response. This information will now be retrieved in two new endpoints: 
   - Get workflows by pipeline `GET /pipeline/{pipeline-id}/workflow`
   - Get scheduled workflows by project `GET /project/{project-slug}/scheduled-workflow`

### Oct 25, 2019

Fixed some typos and clarified some of the changes, specifically around pluralization and error responses.

### Oct 23, 2019

Initial list of proposed changes to v2 preview

## Proposed Changes

The API v2 preview was made available earlier this year with the intent of exposing [new workflow and pipeline control endpoints](https://github.com/CircleCI-Public/api-preview-docs/blob/master/docs/api-changes.md#new-endpoints-available-for-preview-use) to our API users. With the v2 Preview endpoints in place, the team at CircleCI also began to migrate API v1 and v1.1 endpoints into v2.

As we began to migrate endpoints into v2, the team took some time to re-evaluate the design and UX of the overall API itself. It was during this process that we identified some gaps and inconsistencies with how the v2 endpoints behaved. These changes would require us to introduce breaking changes, but contributes to a more consistent and scalable API v2 experience.

The changes we are making fall into one of five general categories:

- [Removed endpoints](#removed-endpoints)
- [Consistent HTTP responses](#consistent-http-responses)
- [Changes to routes](#changes-to-routes)
- [Paginated responses](#paginated-responses)
- [Changes to Reponses](#changes-to-responses)

### Removed endpoints

The list of removed endpoints have already been announced in the original API v2 preview announcement. You can find the list of endpoints that didn't make the transition from v1.1 to v2 [here](https://github.com/CircleCI-Public/api-preview-docs/blob/master/docs/api-changes.md#endpoints-likely-being-removed-in-api-v2-still-available-in-v11-for-now).

In addition to that list, the following endpoint has been removed:

#### Add User to Build

`POST project/:vcs-type/:username/:project/:build_num/ssh-users?circle-token=:token` has been removed because this operation is no longer supported on the CircleCI 2.0 platform.

### Consistent HTTP Responses

We've caught a few situations where some API endpoints don't respond with the expected HTTP Status code. We will be standardizing our HTTP responses to make sure that all our `v2` endpoints provide a consistent HTTP response status.

#### Successful Status Codes

200 OK - responds with a custom payload
201 Created - responds with the created entity
202 Accepted -  responds with `{"message": "Accepted."}`

#### Error Status Codes

##### User Errors

For user fault errors, the error message will be human readable and have enough information for a developer to understand and address the problem.

###### 404 Not Found

Generally responds with:

```
{"message": "some-entity-name not found."}
```

For example, you will see this error code when a resource is not found, or if the URI doesn't exist or is malformed.

###### 400 Bad Request

Generally responds with:

```
{"message": "some-entity-name not found."}
```

For example, you will typically see this error code when query parameters are missing or invalid, or if the request body is invalid.

#### Server Fault Codes

The relevant HTTP 5xx status codes will be used in the situation where a server error occurs. The return body will contain a message. For example:

- 500 Internal Server Error - responds with `{"message": "Internal server error."}`
- 503 Service Unavailable - responds with `{"message": "Service unavailable."}`

### Changes to Routes

- [Get Test Metadata](https://circleci.com/docs/api/v2/#get-test-metadata) endpoint will move from `/project/{project-slug}/{job-number}/tests` to `/project/{project-slug}/job/{job-number}/tests`. Note the addition of `job/` to the route
- [Get a workflow's jobs](https://circleci.com/docs/api/v2/#get-a-workflow-39-s-jobs) `/workflow/{id}/jobs` will be singular and now live under `/workflow/{id}/job`


### Paginated Responses

- [Get an environment variable](https://circleci.com/docs/api/v2/#get-an-environment-variable) response will be paginated
- [Get all checkout keys](https://circleci.com/docs/api/v2/#get-all-checkout-keys) response will be paginated

### Changes to Responses

#### Get a Pipeline
A pipeline could potentially have an unbounded set of workflows associated with it. For that reason we are removing `workflow` from the [get a pipeline](https://circleci.com/docs/api/v2/#get-a-pipeline) response and introducing two new endpoints:

1. Get a pipeline's workflows `GET /pipeline/{pipeline-id}/workflow`
2. Get project's scheduled workflows `GET /project/{project-slug}/scheduled-workflow`