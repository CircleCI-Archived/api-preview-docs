#!/bin/bash -e

# Usage:
# 
#   1. set $CIRCLE_API_TOKEN
#   2. run `./test-v2-api <project_slug> [<branch>]`
#
#   To trigger a pipeline on https://github.com/CircleCI-Public/circleci-cli:
#
#       ./test-v2-api gh/CircleCI-Public/circleci-cli
#
#   The above will trigger on the master branch by default.

_project_slug=$1 # e.g. gh/myorg/myproject
_branch=${2:-"master"}   #optional, defaults to master.
_circle_token=${CIRCLECI_API_TOKEN}

if [ -z "$CIRCLECI_API_TOKEN" ]; then
    echo "ERROR: MISSING CIRCLECI TOKEN"
    echo "You need to set CIRCLECI_API_TOKEN in the environment to use this script."
    exit 1
fi

if [ $# -eq 0 ]
  then
    echo "ERROR: MISSING ARGUMENT"
    echo "You need to provide a project slug as an argument in the form gh/myorg/myproject to run this script."
    exit 1
fi

api_root_endpoint="https://circleci.com/api/v2/"


function call() {
	local url
	local verb
	verb=$1
	url="${api_root_endpoint}${2}?circle-token=${_circle_token}"
	echo -e "Calling URL: ${verb} ${url}"
	echo -e "And now, onto calling with curl"
	local response=$(curl -s -v \
	--header "Accept: application/json" \
	--header "Content-Type: application/json" \
	--data "${3}" \
	-request "${verb} ${url}")
	echo "$response"
}


trigger_pipeline_url="project/${_project_slug}/pipeline"
echo $trigger_pipeline_url
post_data="{ \"branch\": \"${_branch}\"}"

echo "Triggering pipeline of $_project_slug on branch ${_branch} by hitting ${trigger_pipeline_url}"

trigger_response=`call POST $trigger_pipeline_url $post_data`

echo "Trigger response:"
echo $trigger_response
echo "-------"

pipeline_id=`echo $trigger_response | jq '.id'`

echo $pipeline_id




