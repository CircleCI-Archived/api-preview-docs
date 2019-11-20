# Conditional Workflows
New as of June 2019, you can use a `when` clause (we also support the inverse clause `unless`) under a workflow declaration with a boolean value to decide whether or not to run that workflow.

The most common use of this construct is to use a [pipeline parameter](pipeline-parameters.md) as the value, allowing an API trigger to pass that parameter to determine which workflows to run.

Below is an example configuration using two different pipeline parameters, one used to drive whether a particular workflow will run and another to determine if a particular step will run.

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
      - mytestjob

jobs:
  mytestjob:
    steps:
      - checkout
      - when:
          condition: << pipeline.parameters.deploy >>
          steps:
            - run: echo "deploying"
```

The above would prevent the workflow `integration_tests` from being triggered
unless it was invoked explicitly when the pipeline is triggered with the following in the POST body:

```json
{
    "parameters": {
        "run_integration_tests": true
    }
}
```

The `when` key actually accepts any boolean, not just pipeline parameters,
though pipeline parameters will be the primary use of this feature until we implement others. `when` also has an inverse clause called `unless`, which inverts truthiness of the condition.
