# CircleCI API v2 Preview Documentation

## BEFORE YOU START: IMPORTANT DISCLAIMER
The CircleCI v2 API is currently in Preview release. You may use it at will, but this evaluation product is not yet fully supported or considered generally available. We have no plans to change any live endpoints in v2, and we are treating it as production software, but the risk of disruption or breaking changes is higher than our generally available features. All breaking changes will be announced ahead of time in our [breaking changes log](breaking.md) 

Use of the v2 API as long as this notice is in the master branch (current as of June 2019) is done at your own risk and is governed by CircleCI’s Terms of Service.

PREVIEWS ARE PROVIDED "AS-IS," "WITH ALL FAULTS," AND "AS AVAILABLE," AND ARE EXCLUDED FROM THE SERVICE LEVEL AGREEMENTS AND LIMITED WARRANTY. Previews may not be covered by customer support. Previews may be subject to reduced or different security, compliance and privacy commitments, as further explained in the Terms of Service, Privacy Policy and any additional notices provided with the Preview. We may change or discontinue Previews at any time without notice. We also may choose not to release a Preview into "General Availability."


# RESOURCES IN THE PREVIEW DOCS
* [New endpoints in API v2](api-changes.md)
* [New: Pipeline parameters](pipeline-parameters.md)
* [New: Conditional workflows](conditional-workflows.md)



# tldr

The CircleCI v2 API behaves very similarly to our v1.1 API. For instance, to get back basic information about the user associated with an API token in v2 you could run (assuming you have set CIRCLECI_TOKEN in your environment):

`curl -u ${CIRCLECI_TOKEN} https://circleci.com/api/v2/me`


## GETTING STARTED WITH CIRCLECI API v2
The v2 API is very similar to our currently documented v1.1 API with some notable exceptions. For details on see the file [docs/api-changes.md](api-changes.md) in this repository, originally at <https://github.com/CircleCI-Public/api-preview-docs>.

Here is a simple example using `curl` to trigger a pipeline with parameters (NOTE: see [docs/pipeline-parameters.md](pipeline-parameters.md) in this repository for more on pipeline parameters, as they behave differently from parameters in the 1.1 job triggering endpoint):

```
curl -u ${CIRCLECI_TOKEN}: -X POST --header "Content-Type: application/json" -d '{
  "parameters": {
    "myparam": "./myspecialdir",
    "myspecialversion": "4.8.2"
  }
}' https://circleci.com/api/v2/project/${project_slug}/pipeline
```

In the above example the `project_slug` would take the form `:vcs/:org/:project`. For instance the project slug `gh/CircleCI-Public/circleci-cli` tells CircleCI to use the project found in the GitHub organization `CircleCI-Public` in the repository named `circleci-cli`.

# Where next?
Dive in by reviewing [the new endpoints in API v2](api-changes.md).
