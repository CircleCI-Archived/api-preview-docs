# Breaking Changes

## Oct 17, 2019

- `start_time` and `stop_time` parameters have been renamed to `started_at` and `stopped_at` to be consistent with other time-based information fields like `created_at` and `queued_at`. This change affects the [Get a Workflow's Job](https://circleci.com/docs/api/v2/#get-a-workflow-39-s-jobs) endpoint
- Cancelling a job is no longer a `POST` to `/project/:project-slug/job/:jobnum`. The job cancellation action is now a `POST` to `/project/:project-slug/job/:jobnum/cancel`

# Proposed Breaking Changes

## Oct 21, 2019

The API v2 preview was made available earlier this year with the intent of exposing [new workflow and pipeline control endpoints](https://github.com/CircleCI-Public/api-preview-docs/blob/master/docs/api-changes.md#new-endpoints-available-for-preview-use) to our API users. With the v2 Preview endpoints in place, the team at CircleCI also began to migrate API v1 and v1.1 endpoints into v2.

As we began to migrate endpoints into v2, the team took some time to re-evaluate the design and UX of the overall API itself. It was during this process that we identified some gaps and inconsistencies with how the v2 endpoints behaved. These changes would require us to introduce breaking changes, but contributes to a more consistent and scalable API v2 experience.

The changes we are making fall into one of five general categories:

- Removed endpoints
- HTTP responses
- Changes to routes
- Paginated responses
- Representation of objects in responses.

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
202 Accepted -  responds with `{“message”: “Accepted.”}`

#### Error Status Codes

##### User Errors

For user fault errors, the error message will be human readable and have enough information for a developer to understand and address the problem.

###### 404 Not Found

Generally responds with:

``` json
{“message”: “some-entity-name not found.”}
```

For example, you will see this error code when a resource is not found, or if the URI doesn't exist or is malformed.

###### 400 Bad Request

Generally responds with:

``` json
{
    “errors”: [{“type”:  “error-type”,
                “value”: “some value”}...]
}
```

For example, you will typically see this error code when query parameters are missing or invalid, or if the request body is invalid.

#### Server Fault Codes

The relevant HTTP 5xx status codes will be used in the situation where a server error occurs. The return body will contain a message explaining the error. For example:

- 500 Internal Server Error - responds with `{“message”: “Internal server error.”}`
- 503 Service Unavailable - responds with `{“message”: “Service unavailable.”}`

### Changes to Routes

- [Get Test Metadata](https://circleci.com/docs/api/v2/#get-test-metadata) endpoint will move from `/project/{project-slug}/{job-number}/tests` to `/project/{project-slug}/job/{job-number}/tests`. Note the addition of `job/` to the route
- References to `project/` will be pluralized to `projectS/` e.g.
  - `/project/{project-slug}` -> `/projects/{project-slug}`
  - `/project/{project-slug}/job/{job-number}` -> `/projects/{project-slug}/job/{job-number}`
- References to `pipeline/` will be pluralized to `pipelineS/` e.g.
  - `/pipeline/{pipeline-id}` -> `pipelineS/{pipeline-id}`
  - `/pipeline/{pipeline-id}/config` -> `/pipelineS/{pipeline-id}/config`
- References to `job/` will be pluralized to `jobS/` e.g.
  - `/project/{project-slug}/job/{job-number}` -> `/project/{project-slug}/jobS/{job-number}`
- References to `workflow/` will be pluralized to `workflowS/` e.g.
  - `/workflow/{id}` -> `/workflowS/{id}`

### Paginated Responses

- [Get an environment variable](https://circleci.com/docs/api/v2/#get-an-environment-variable) response will be paginated
- [Get all checkout keys](https://circleci.com/docs/api/v2/#get-all-checkout-keys) response will be paginated

### Representation of Objects in Responses

We're also proposing a change the shape of how objects will be represented in our responses:

#### Users

``` json
{
   “id”: "UUID",
   “name”: “Circler"
}
```

#### External Identity

``` json
{
   “id”: “external-id”,
   “login”: “login”,
   “avatar_url”: "https://example.com",
   “name”: "Circler",
   “web_url”: "https://github.com/circler"
}
```

#### Project (Short)

``` json
{
   “slug”: "gh/circleci/example-project",
   “name”: “example-project”,
   “external_url”: “https://github.com/circleci/example-project”
}
```

#### Project (Full)

``` json
{
  “slug”: "gh/circleci/example-project",
  “name”: “example-project”,
  “external_url”: “https://github.com/circleci/example-project”,
  “organization”: {...} // Organization Short
}
```

Note that the following keys will be removed from this response:

- `organization_name`
- `vcs`

#### Organization (Short)

``` json
{
   “slug”: “gh/circleci”,
   “name”: “circleci”
}
```

#### Job (Short)

``` json
{
   “id”: “uuid”,
   “name”: "deploy-service",
   “number”: 5327,
   “type”: “build”

   “status”: {
      “name”: "canceled",
      // null or object
      “details”: {
         “canceler”: {
             “user”: {...}, // User Short
             “external_identity”: {...} // External Identity Full
   },

   “started_at”: "2019-09-05T19:13:30.236Z",
   “stopped_at”: "2019-09-05T19:13:49.909Z",

   “project”: {...}, // Project Short
}
```

Note that the following keys will be removed from this response:

- `project_slug`
- `dependencies`

#### Job (Full)

``` json
{
   “id”: “uuid”,
   “name”: "deploy-service",
   “number”: 5327,
   “type”: “build”,

   “status”: {
      “name”: "canceled",
      // null or object
      “details”: {
         “canceler”: {
             “user”: {...}, // User Short
             “external_identity”: {...} // External Identity Full
   },
 
   “contexts”: [
      {“name”: "org-global"}
   ],
 
   “latest_workflow”: {...}, // Workflow Short

   “pipeline”: {...}, // Pipeline Short


   “created_at”: "2019-09-05T19:13:28.049Z",
   “queued_at”: "2019-09-05T19:13:28.107Z",
   “started_at”: "2019-09-05T19:13:30.236Z",
   “stopped_at”: "2019-09-05T19:13:49.909Z",
   “duration”: 19673,
 
   “parallelism”: 1,
   “parallel_runs”: [
      {
         “index: 0
         “status”: "success"
      }
   ],

   “web_url”: "https://circleci.com/gh/circleci/domain-service/5327",
 
   “project”: {...}, // Project Short

   “organization”: {...}, // Organization Short
 
   “messages”: [
      {
         “type”: "warning",
         “message”: "'xxx' is not configured as a white-listed branch.",
         “reason”: "branch-not-whitelisted"
      }
   ],

   “executor”: {
      “type”: "docker",
      “resource_class”: "medium"
   }
}
```

#### Workflow (Short)

``` json
{
  "id": "string",
  "name": "build-and-test",
  "status": {
     “name”: "success",
     “details”: null // see Job Full
  },
}
```

#### Workflow (Full)

``` json
{
  "id": "string",
  "name": "build-and-test",

  "status": {
     “name”: "success",
     “details”: null // see Job Full
  },

  "created_at": "2019-10-04T22:04:35Z",
  "stopped_at": "2019-10-04T22:04:35Z",

  "pipeline": {...}, // Pipeline Short
  "project": {...}   // Project Short
}
```

Note that the following keys will be removed from this response:

- `pipeline_id`
- `pipeline_number`
- `project_slug`

#### Pipeline (Short)

``` json
{
  "id": "string",
  "number": 1,
  “status”: {...},
  “created_at”: “2019-10-07T14:07:33Z”,
  “project”: {...} // Project Short
}
```

#### Pipeline (Full)

``` json
{
  "id": "string",
  "number": 0,

  "status": {
     “name”: "dont_run",
     “details”: {
       “reason”: [“ci-skip”|”branch-not-whitelisted”|...”]
     }
  },

  "last_workflows": [
    {...} // 10 last Workflow Short
  ],
  
  "errors": [
    {
      "type": "config",
      "message": "string"
    }
  ],

  "project": {...}, // Project Short

  "created_at": "2019-10-04T22:04:35Z",

  "trigger”: {
    "branch”: “master”,
    "tag”: “v3.1.4159”,
    "revision”: “sha”,
    “parameters”: {
      “name”: “value”
    }
    "by”: {
      "user”: {...}, // User Short
      "external_identity”: {...} // External Identity Full
    }
  }
```

Note that the following keys will be removed from this response:

- `project_slug`
- `updated_at`
- `state`
- `vcs`
- `trigger.type`
- `trigger.received_at`
- `trigger.actor`

#### Checkout Key (Full)

``` json
{
  "public_key": "ssh-rsa ...",
  "type": "deploy-key",
  "fingerprint": "c9:0b:1c:4f:d5:65:56:b9:ad:88:f9:81:2b:37:74:2f",
  "preferred": true,
  “created_at”: "2015-09-21T17:29:21.042Z"
}
```

Note that the following keys will be removed from this response:

- `time`

#### Environment Variable (Full)

``` json
{
  "name": "foo",
  "value": "xxxx1234"
}
```

#### Status (Full)

``` json
   “status”: {
      “name”: "canceled",
      // null or object
      “details”: {
         “canceler”: {
             “user”: {...}, // User Short
             “external_identity”: {...} // External Identity Full
   },

   "status": {
      “name”: "success",
      “details”: null
   },

   "status": {
      “name”: "dont_run",
      “details”: {
        “reason”: [“ci-skip”|”branch-not-whitelisted”|...”]
      }
}
```

Note that the contents of `details` may vary based on the value of `status`
