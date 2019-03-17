
# API changes compared to version 1.1

## New features in API v2

**COMING SOON**

### GET /workflow/:id
Retrieve an individual workflow by its unique ID.

### POST /project/:vcs-type/:username/:project/pipeline
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
