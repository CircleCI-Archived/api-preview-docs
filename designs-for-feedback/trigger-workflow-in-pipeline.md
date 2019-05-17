# Request for Comment: Trigger an individual workflow

## Problem statement
Users want to be able to trigger a pipeline, selecting a specific workflow in the configuration to run. They also need a way for such manually triggered workflows to not always run when the pipeline is triggered without specifying a particular workflow.

## Proposed solution
1. We will add a parameter to the triggering of pipelines (`POST /project/:project_slug/pipeline`) to specify a particular workflow by name.
2. We will also add a new way to specify in config to not run a particular workflow unless it is explicitly triggered.

## Design options for the new triggering parameter.
In v1.1 we combined the custom parameters passed into a build with our built-in parameters, passing them all when triggering a job as a single name/value collection. In v2 we plan to separate out your custom parameters from built-in flags and settings.

When you want to trigger an individual workflow in a configuration file we can either:

1. Add a new, optional triggering parameter called `workflow` or `workflow_name` that will be passed in the body of your POST when triggering a pipeline. The benefits of this approach is that it's explicit about the intent, easy to read in code, and straight-forward to debug. The potential downside is that if and when we add the ability to trigger an individual job or add other specialized triggering instructions it will start to create a crowded set of new built-in parameters.
2.  Add a new, optional triggering parameter called something like `scope` or `trigger-scope` that takes a complex object that would look something like `{workflow-name: foo}`. The benefits of this is that we could include things like the branch or tag or SHA within that object, unifying all the various trigger-time settings into a single, extensible object. The downside is added syntactic complexity (and the commensurate cognitive/documentation complexity) and more open-ended debugging.

Working assumption: we will go with option 1 above.

## Design options for configuration of workflows
If a pipeline configuration contains multiple workflows the behavior today is to run them both immediately upon triggering. With the ability to trigger a particular workflow via the API, users will likely want to be able to configure workflows intended to be run only when explicitly triggered and not run when a normal webhook from GitHub or other VCS system is received upon a push to the repo. Thus, we need to introduce some mechanism to declare under what circumstances certain workflows in a configuration should be run.

Working assumption is that we will add a new valid value like `explicit` or `manual` for the existing `triggers` stanza to only trigger the workflow when it's explicitly invoked. That might look like one of the following:

```
workflows:
  foo:
    triggers:
      - explicit
```

The above would prevent the workflow `foo` from being triggered unless it was invoked explicitly when the pipeline is triggered.


