# Setup Workflows, Path Filtering, and Monorepos

CircleCI has so far not had any first-class monorepo support. One common problem this entails for monorepo users is that every push runs the entire CI suite.

The work to be run is defined in CircleCI configuration, which is fetched and compiled before any workflow is created or run. As such it cannot be dynamically changed based on the changes in the repository, for example just build the components of a monorepo which have actually changed.


## Setup Workflows

Setup workflows are a new opt-in CircleCI feature which allows the running of a workflow to dynamically generate a CircleCI configuration and pipeline parameters, and then run the resulting work within the same pipeline. This way it sidesteps the limitation outlined above and enables dynamic work discovery.

To this end, the pipeline enters a new `setup` phase (as denoted by the `setup` stanza in the configuration), during which a single workflow can be run. The jobs in this workflow have access to a special `continuation-key`, which can be used to call the public continuation API at [/api/v2/pipeline/continue](https://circleci.com/docs/api/v2/#operation/continuePipeline). This call includes a new configuration file, as well as pipeline parameters. The pipeline is then advanced to the regular `created` phase. A pipeline can only be continued once, and only within 6 hours.

If a pipeline enters the `setup` phase, the configuration used initially is called the `setup config`, and is stored alongside the regular configuration.

The `continuation-key` is injected into the jobs as a secret environment variable, `$CIRCLE_CONTINUATION_KEY`, and excluded from API responses and step output. We strongly recommend against extracting it from the job, as it allows submission of arbitrary configurations, and thus could potentially be used to extract secrets from restricted contexts.

![img](./setup-workflows.png "Flow")


## Using the Path Filtering Orb

To reduce the boilerplate required for a monorepo setup, we have created a set of orbs to implement path filtering and [automatic continuation](https://circleci.com/developer/orbs/orb/sandbox/continuation).

First, you need to enable setup workflows for your project (Project Settings -> Advanced -> At the bottom). After signing up to the preview, navigate to the project settings page on CircleCI and enable the "Run Setup Workflows" setting.

The following steps can happen on a feature branch.

Move your existing config to `.circleci/continue_config.yml`.

Separate out the tests for different components into separate workflows, and gate them on pipeline parameters, like so:

```yaml
version: 2.1

parameters:
  build-server:
    type: boolean
    default: false
  build-client:
    type: boolean
    default: false

jobs:
  - [...]

workflows:
  build-server:
    when: << pipeline.parameters.build-server >>
    jobs:
      - [...]
  build-client:
    when: << pipeline.parameters.build-client >>
    jobs:
      - [...]
```

The `equal` statements ensure that the workflows always run on the default branch, i.e. after merging.

Place this config at `.circleci/config.yml`:

```yaml
version: 2.1

setup: true

orbs:
  path-filtering: circleci/path-filtering@0.0.1

workflows:
  setup-workflow:
    jobs:
      - path-filtering/filter:
          mapping: |
            src/server/.* build-server true
            src/client/.* build-client true
          # Optional, defaults to main:
          base-revision: origin/develop
```

Match the paths and parameters in the mapping to your project.

The mappings consist of three whitespace-separated elements, a regular expression matching a path, a pipeline parameter, and a value for that parameter.

The mappings are evaluated in order. If the regular expression matches any file changed between the base revision and the current `HEAD`, the pipeline parameter will be set to the value specified. Later matches override earlier ones. **Note**: If `base-revision` is a non-default branch, it needs to be prefixed with `origin/`, as it will not be fetched by default.

The regular expressions support the full [Python re syntax](https://docs.python.org/3.8/library/re.html#regular-expression-syntax), and are automatically enclosed by `^` and `$` to prevent partial matches.


## Further Reading

You can find more information about the elements used here:

-   [Pipeline Variables](https://circleci.com/docs/2.0/pipeline-variables/)
-   [Logic Statements](https://circleci.com/docs/2.0/configuration-reference/#logic-statements)
-   [Conditional Steps](https://circleci.com/docs/2.0/reusing-config/#defining-conditional-steps)
-   [Introduction to Orbs](https://circleci.com/docs/2.0/orb-intro/)
