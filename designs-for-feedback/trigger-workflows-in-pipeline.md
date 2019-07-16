
# NOTE: THIS DESIGN DOCUMENT IS NOW OBSOLETE.
PLEASE SEE [THE DOC ON CONDITIONAL WORKFLOWS](../docs/conditional-workflows.md) FOR INFO ON THE ACCEPTED IMPLEMENTATION.






## Problem statement
Users want to be able to trigger a pipeline, selecting a specific workflow in
the configuration to run. They also need a way for such manually triggered
workflows to not always run when the pipeline is triggered without specifying a
particular workflow.

## Proposed solution
We will add new semantics to workflows configuration which will use pipeline
parameters (and potentially other types of values in the future) to determine
whether a particular workflow should run within a pipeline. Standard pipeline
parameters can then be passed in to select which workflows should be run.

## Design options for configuration of workflows
If a pipeline configuration contains multiple workflows the behavior today is to
run them both immediately upon triggering. With the ability to trigger a
particular workflow via the API, users will likely want to be able to configure
workflows intended to be run only when explicitly triggered and not run when a
normal webhook from GitHub or other VCS system is received upon a push to the
repo. Thus, we need to introduce some mechanism to declare under what
circumstances certain workflows in a configuration should be run.

The currently planned solution uses the existing pipeline parameters feature
coupled with some new semantics within workflows to decide whether a workflow
will be run. This feature requires pipelines to be enabled on the project, and a
configuration of version 2.1 (or newer).

```yaml
version: 2.1

parameters:
  run_integration_tests:
    type: boolean
    default: false
  deploy:
    type: boolean
    default: false

workflows:
  version: 2
  integration_tests:
    when: << pipeline.parameters.run_integration_tests >>
    jobs:
      - tests
      - when:
          condition: << pipeline.parameters.deploy >>
          steps:
            - deploy

jobs:
  ...
```

The above would prevent the workflow `integration_tests` from being triggered
unless it was invoked explicitly when the pipeline is triggered with:

```json
{
    "parameters": {
        "run_integration_tests": true
    }
}
```

The `when` key actually accepts any boolean, not just pipeline parameters,
though pipeline parameters will be the only meaningful use of this feature until
we implement others. 

`when` would also come with an alternative of `unless`, which inverts truthiness
of the condition.

The use of pipeline parameters has the following benefits:

- Pipeline parameters are an existing feature which is planned to be used more
  widely, and thus limit the need for additional documentation and generally
  limit the semantics of configuration through reuse.
- They allow custom grouping and defaults, giving users more control over the
  structure of their workflows without incurring additional complexity on our
  side. Users could for example reuse the same parameter for several workflows
  which should always run together.
