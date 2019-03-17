# Pipeline Parameters

Pipeline parameters are new with API v2. To use pipeline parameters you must use configuration version 2.1 or higher.

## Declaring and using pipeline parameters in configuration

Pipeline parameters are declared using a `parameters` stanza in the top level  keys of your `.circleci/config.yml` file. You can then reference the value of the parameter as a config variable in the scope `pipelines.parameters`. 

The example belows shows a config with two pipeline parameters, `image-tag` and `workingdir` both used on the subsequent config stanzas:

```
version: 2.1
parameters:
  image-tag:
    type: string
    default: "latest"
  workingdir:
    type: string
    default: "./main"

jobs:
  build:
    docker:
      - image: circleci/node:<< pipelines.parameters.image-tag >>
    environment:
      IMAGETAG: << pipelines.parameters.image-tag >>
    working_directory: << pipelines.parameters.workingdir >>
    steps:
      - echo "Image tag used was ${IMAGETAG}"
```


## Passing parameters when triggering pipelines via the API
Use the API v2 endpoint to trigger a pipeline, passing the `pipeline_parameters` key in the JSON packet in your POST body.

The example below triggers a pipeline with the parameters in the above config example (_NOTE: To pass a parameter when triggering a pipeline via the API the parameter must be declared in the configuration file._).

```
curl -X POST --header "Content-Type: application/json" -d '{
  "pipeline_parameters": {
    "workingdir": "./myspecialdir",
    "image-tag": "4.8.2"
  }
}

https://circleci.com/api/v2/project/:vcs-type/:username/:project/pipeline?circle-token=:token
```

## The scope of pipeline parameters
Pipeline parameters can only be resolved in the `.circleci/config.yml` file in which they are declared. Pipeline parameters are not available in orbs, including orbs declared locally in your config.yml file. We made this design decision because access to the pipeline scope in orbs would break encapsulation and create a hard dependency between the orb and the calling config, jeopardizing determinism and creating surface area of vulnerability.


