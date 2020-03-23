
# What's new in API v2?

## BEFORE YOU START: IMPORTANT DISCLAIMER
The CircleCI v2 API is currently in Preview release. You may use it at will, but this evaluation product is not yet fully supported or considered generally available. We have no plans to change any live endpoints in v2, and we are treating it as production software, but the risk of disruption or breaking changes is higher than our generally available features.

Use of the v2 API as long as this notice is in the master branch (current as of June 2019) is done at your own risk and is governed by CircleCI’s Terms of Service.

PREVIEWS ARE PROVIDED "AS-IS," "WITH ALL FAULTS," AND "AS AVAILABLE," AND ARE EXCLUDED FROM THE SERVICE LEVEL AGREEMENTS AND LIMITED WARRANTY. Previews may not be covered by customer support. Previews may be subject to reduced or different security, compliance and privacy commitments, as further explained in the Terms of Service, Privacy Policy and any additional notices provided with the Preview. We may change or discontinue Previews at any time without notice. We also may choose not to release a Preview into "General Availability."

## NOTE ON AUTHENTICATION
Use of the below endpoints is similar to use of the version 1.1 endpoints in terms of authentication. A simple way to authenticate is to send your API token as the username of the HTTP request. For instance, let's say you have set `CIRCLECI_TOKEN` in your shell's environment. You could then use `curl` with that token like this:

`curl -u ${CIRCLECI_TOKEN}: https://circleci.com/api/v2/me`

Please refer to the main CirlceCI API documentation for more details on authenticating with a token.

##  NEW: THE `project_slug` as a string
The CircleCI v2 API is backwards compatible with previous API versions in the way it identifies your projects using repository name. For instance, if you want to pull information from CircleCI about the GitHub repository <https://github.com/CircleCI-Public/circleci-cli> you can refer to that in the CircleCI API as `gh/CircleCI-Public/circleci-cli`, which is a "triplet" of the project type, the name of your "organization", and the name of the repository. For the project type you can use `github` or `bitbucket` as well as the shorter forms `gh` or `bb`, which are now supported in API v2). The organization is your username or organization name in your version control system.

With API v2 we are introducing a string representation of the triplet called the `project_slug`, takes the form: `<project_type>/<org_name>/<repo_name>`. The `project_slug` is included in the payload when pulling information about a project as well as when looking up a pipeline or workflow by ID. The `project_slug` can then be used to get information about the project. It's possible in the future we could change the shape of a `project_slug`, but in all cases it would be usable as a human-readable identifier for a given project.

## NEW: Insights endpoints

With CircleCI v2 Insights endpoints, you can view the recent runs of your named workflows. The insights endpoints contains status, duration and credits consumed information.

## NEW ENDPOINTS AVAILABLE FOR PREVIEW USE.
Note, all endpoints below are relative to:

`https://circleci.com/api/v2`

### GET /workflow/:id
Retrieve an individual workflow by its unique ID.

### GET /workflow/:id/job
Retrieve the jobs of an individual workflow by its unique ID. Note that for now we're returning all jobs, but we reserve the right to paginate them in the future. The shape of the pagination will not change, but the default number of jobs may be reduced.

### GET /project/:project_slug
Retrieve an individual project by its unique slug.

### POST /project/:project_slug/pipeline
Trigger a new pipeline run on a project.

To trigger with parameters you pass a `parameters` map inside a JSON object as part of the POST body. For details on passing pipeline parameters when triggering pipelines with the API see the [pipeline parameters documentation](pipeline-parameters.md). Note that pipeline parameters can also be used to populate a `when` or `unless` clause on a workflow to conditionally run one or more workflows. See the [conditional workflows](conditional-workflows.md) doc for more information.

To trigger on a specific branch pass a parameter `branch` in the post body. For instance, it might look like:

```
curl -u ${CIRCLECI_TOKEN}: -X POST --header "Content-Type: application/json" -d '{
  "branch": "dev"
}' https://circleci.com/api/v2/project/${project_slug}/pipeline
```


### GET /project/:project_slug/pipeline/
Retrieve recent set of pipelines for a project.

### GET /pipeline/:id
Retrieve a particular pipeline by its unique ID. This will return basic information about the pipeline, including triggering information and the IDs of running workflows associated with the pipeline. Please note that workflows are created asyncronously to the creation of a pipeline, so in automated scripts if you trigger a pipeline it may not immediately have knowledge of all workflows that will be run as a result of your trigger. You may need to make subsequent, delayed requests to get all workflow IDs. In most cases this should be a matter of a few seconds, but in some situations the queues between our pipeline ingestion machinery and our workflows conductor can take longer to proceed.

### GET /pipeline/:id/config
Retrieve the configuration (both the source and compiled versions) for a given pipeline.

### Run only workflows conditioned on API parameters
Use the new `when` clause under a workflow, you can use the value of a boolean pipeline parameter to conditionally start specific workflows. See the documentation on [conditional workflows](conditional-workflows.md) for more.

### GET openapi.json or GET openapi.yml
Gives you the current production OpenAPI spec for the v2 API (eg: <https://circleci.com/api/v2/openapi.json> )

### GET /insights/:project-slug/workflows?branch=":branch-name"
Retrieve aggregate data about project workflows for a specified branch. The aggregation window is the shorter of the last 90 days, or the last 250 executions. If no branch is selected, CircleCI will provided data for the default branch. The payload contains the following fields:

- Workflow name
- Aggregation window start (UTC)
- Aggregation window end (UTC)
- Successful runs
- Failed runs
- Total runs
- Success rate
- Throughput (average number of runs / day)
- Total credits used
- Duration statistics: max, min, mean, median, p95, standard deviation (all in seconds)

### GET /insights/:project-slug/workflows/:workflow-name?branch=":branch-name"
Retrieve the recent 250 runs (within the last 90 days) of a named project workflow for a specified branch. If no branch is selected, CircleCI will provide data for the default branch. The payload contains the following fields:

- Workflow ID
- Status
- Credits used
- Duration (seconds)
- Created at (UTC)
- Stopped at (UTC)

## Endpoints likely being removed in API v2 (still available in v1.1 for now)
### POST    /project/:vcs-type/:username/:project
In v2 and forward you can only trigger a pipeline using the new endpoint. This endpoint will be removed in v2 and deprecated in v1.1 (note that this endpoint is not compatible with pipelines, so if you turn on pipelines it won't work properly. Please migrate to the new endpoint)

### POST    /project/:vcs-type/:username/:project/:build_num/retry

### POST    /project/:vcs-type/:username/:project/build
Replaced by POST /project/:vcs-type/:username/:project/pipeline

### DELETE  /project/:vcs-type/:username/:project/build-cache
Note that 'build cache' is a concept from legacy CircleCI. Caches in our new platform are immutable.

### GET /recent-builds
This will be replaced by the ability to retrieve recent pipelines.

## Other changes in v2
* If you do not provide an ACCEPT header, the v2 API will return JSON. This is a change from 1.1, which would default to EDN.
