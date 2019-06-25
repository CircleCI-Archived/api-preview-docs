#! /bin/bash

#********************
# VARIABLES
# *******************
path_to_cli_config='~/.circleci/cli.yml'
circleci_root='https://circleci.com/'
api_root="${circleci_root}api/v2/"
cli_config_path="${HOME}/.circleci/cli.yml"
project_slug="gh/ndintenfass/scratch"
parameter_map='{"workingdir": "~/myspecialdir", "image-tag": "4.8.2"}'
# branch="tryapi"

#********************
# FUNCTIONS
# *******************

roman() {
    local values=( 1000 900 500 400 100 90 50 40 10 5 4 1 )
    local roman=(
        [1000]=M [900]=CM [500]=D [400]=CD 
         [100]=C  [90]=XC  [50]=L  [40]=XL 
          [10]=X   [9]=IX   [5]=V   [4]=IV 
           [1]=I
    )
    local nvmber=""
    local num=$1
    for value in ${values[@]}; do
        while (( num >= value )); do
            nvmber+=${roman[value]}
            ((num -= value))
        done
    done
    echo $nvmber
}


current_section=0
current_step=0
section () {
  ((current_section++))
  # reset the step numbering at each section
  current_step=0
  echo "************* $(roman current_section). ${1} *************"
}


step () {
  ((current_step++))
  echo "${current_step}. ${@: -1}"
  echo ""
}

error () {
  section 'GAME OVER'
  echo $1
  exit 1
}

require_command () {
  cli_exists=$(which $1)
  if [[ -z $cli_exists ]]; then
    error "${1} is required, and you don't seem to have it. Aborting because this script won't work without ${1}."
  fi
  step "${1} is required, and it looks like you have it installed. Proceeding..."
}

gather () {
  read -p read -p "${1}`echo $'\n> '`" var
  echo $var
  return 0
}


choice () {
  while true; do
    read -p "${1}. Answer y or n. " yn
    case $yn in
      [Yy]* ) echo; break;;
      [Nn]* ) section "IN THAT CASE, HAVE A GOOD DAY. SEE YOU NEXT TIME."; echo 'exiting...'; exit;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

set_token () {
  step "You are using circleci CLI version $(circleci --skip-update-check version). This script will now look in your circleci CLI config to get a token value to use. (NOTE: For now this script assumes you use the default location for that config, but a nice improvement later would be to update this script to suss out the location using the diagnostic command of the circleci CLI.)"
  if [ -f "$cli_config_path" ]; then
    circle_token=$(yq r "${cli_config_path}" token)
  else
    circle_token=$(gather \
    "You do not appear to have a config for your CLI at ${cli_config_path}, so to use this script you will need to enter your token manually.")
  fi
  step "A CircleCI token is set."
}

ensure_project_slug () {
  if [[ ! $project_slug ]]; then
    project_slug=$(gather \
      "Enter your project slug in the form ':type/:org/:project',\
      for instance valid project slug would look like\
      'gh/CircleCI-Public/circleci-cli'.")
  fi
  echo ${BASH_SOURCE[0]}
  step "Your project_slug is set to ${project_slug}. You can change this in the file $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
}

post () {
  local url="${api_root}${1}"
  curl -su ${circle_token}: -X POST \
       --header "Content-Type: application/json" \
       -d "$2"\
       "${url}"
}

get () {
  local url="${api_root}${1}"
  curl -su ${circle_token}: \
       --header "Content-Type: application/json" \
       "${url}"
}

#********************
# PREAMBLE AND SETUP
# *******************
section 'INTRO: A QUICK RUN THROUGH OF THE v2 API'
step 'Hello, this script runs through some really simple cases enabled by the CircleCI v2 API's
section 'CHECK PREREQUISITES'
require_command git
require_command circleci
require_command yq
require_command jq
ensure_project_slug
section 'SETUP SOME VARIABLES'
set_token
section 'TRY TRIGGERING AND RETRIEVING A PIPELINE'
step "Attemping to trigger a pipeline on the project ${project_slug}"
params="{\"parameters\": ${parameter_map} }"
result=$(post "project/${project_slug}/pipeline" "${params}")
pipeline_id=$(echo $result | jq -r .id)
step "Successfully created pipeline with ID $pipeline_id"
get_path="pipeline/${pipeline_id}"
result=$(get $get_path)
step "GET pipeline by ID: /${get_path} - the raw payload is below"
echo $result
