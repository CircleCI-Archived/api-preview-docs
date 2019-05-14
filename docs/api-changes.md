
# What's new in API v2?

## BEFORE YOU START: IMPORTANT DISCLAIMER
The CircleCI v2 API is currently in Preview release. You may use it at will, but this evaluation product is not yet fully supported or considered generally available.

Use of the v2 API as long as this notice is in the master branch (current as of May 2019) is done at your own risk and is governed by CircleCI’s Terms of Service.

PREVIEWS ARE PROVIDED "AS-IS," "WITH ALL FAULTS," AND "AS AVAILABLE," AND ARE EXCLUDED FROM THE SERVICE LEVEL AGREEMENTS AND LIMITED WARRANTY. Previews may not be covered by customer support. Previews may be subject to reduced or different security, compliance and privacy commitments, as further explained in the Terms of Service, Privacy Policy and any additional notices provided with the Preview. We may change or discontinue Previews at any time without notice. We also may choose not to release a Preview into "General Availability."

## NOTE ON AUTHENTICATION
Use of the below endpoints is similar to use of the version 1.1 endpoints in terms of authentication. Please refer to the main CirlceCI API documentation for information on authenticating with a token.

##  NEW: THE `project_slug` as a string
The CircleCI v2 API is backwards compatible with previous API versions in the way it identifies your projects using repository name. For instance, if you want to pull information from CircleCI about the GitHub repository <https://github.com/CircleCI-Public/circleci-cli> you can refer to that in the CircleCI API as `gh/CircleCI-Public/circleci-cli`, which is a "triplet" of the project type, the name of your "organization", and the name of the repository. For the project type you can use `github` or `bitbucket` as well as the shorter forms `gh` or `bb`, which are now supported in API v2). The organization is your username or organization name in your version control system.

With API v2 we are introducing a string representation of the triplet called the `project_slug`, takes the form: `<project_type>/<org_name>/<repo_name>`. The `project_slug` is included in the payload when pulling information about a project as well as when looking up a pipeline or workflow by ID. The `project_slug` can then be used to get information about the project. It's possible in the future we could change the shape of a `project_slug`, but in all cases it would be usable as a human-readable identifier for a given project.

## NEW ENDPOINTS AVAILABLE FOR PREVIEW USE.

### GET /workflow/:id
Retrieve an individual workflow by its unique ID.

### GET /workflow/:id/jobs
Retrieve the jobs of an individual workflow by its unique ID. Note that for now we're returning all jobs, but we reserve the right to paginate them in the future. The shape of the pagination will not change, but the default number of jobs may be reduced.

### GET /project/:project_slug
Retrieve an individual project by its unique ID.

## COMING SOON

### POST /project/:project_slug/pipeline
Trigger a new pipeline run on a project. This endpoint will also soon have the ability to [pass parameters available during configuration processing](pipeline-parameters.md) as well as the ablity to trigger a particular branch and/or a particular workflow in your configuration.

### GET /pipeline/:id
Retrieve a particular pipeline by its unique ID. This will return basic information about the pipeline, including triggering information and the IDs of running workflows associated with the pipeline. Please note that workflows are created asyncronously to the creation of a pipeline, so in automated scripts if you trigger a pipeline it may not immediately have knowledge of all workflows that will be run as a result of your trigger. You may need to make subsequent, delayed requests to get all workflow IDs. In most cases this should be a matter of a few seconds, but in some situations the queues between our pipeline ingestion machinery and our workflows conductor can take longer to proceed.

### GET /project/:vcs-type/:username/:project/pipelines/[:filter]
Retrieve recent set of pipelines for a project. The shape of the filter will be documented once this endpoint is ready to be previewed. Filters may be used to retrieve pipelines for a given branch, for instance. _PREVIEW NOTE: We may change this to be more a more generic method for retrieving piplines by project, by organization, or by triggerer. If we stick with a project-oriented endpoint like this one we may not ship filters in the initial release, but we want to hear about your use cases for filtering._

## Endpoints being removed in API v2 (still available in v1.1 for now)
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
* If you do not provide an ACCEPT header, the v2 API will return JSON. This is a change from 1.1, w hich would default to EDN.
