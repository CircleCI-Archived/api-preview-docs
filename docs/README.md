# CircleCI API v2 Preview Documentation

# RESOURCES IN THE PREVIEW DOCS
* [Changes in API v2](api-changes.md)
* [Pipeline parameters](pipeline-parameters.md)

# BASICS

The CircleCI v2 API behaves very similarly to our v1.1 API. For instance, to get back basic information about the user associated with an API token in v2 you could run (assuming you have set CIRCLECI_TOKEN in your environment):

`curl -u ${CIRCLECI_TOKEN} https://circleci.com/api/v2/me`


