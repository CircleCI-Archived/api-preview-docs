#! /bin/bash
set -e
set -o pipefail
set -o functrace

# TODO: Not tolerant of initial trigger failing to create any workflows in time - should have some retry logic.
# TODO: Does not check for pipeline errors
# TODO: Does not know all possible status values for workflows
# TODO: Only gets jobs for workflows still running when initially retrieved


#********************
# VARIABLES
# *******************

# **** !!!!
# **** CHANGE THESE TO REFLECT YOUR PROJECT
# **** AND THE PARAMETERS YOU WANT TO SEND
# **** !!!!
project_slug="gh/ndintenfass/scratch"
parameter_map='{"workingdir": "~/myspecialdir", "image-tag": "4.8.2"}'


# YOU LIKELY DO NOT NEED TO EDIT THESE OR ANYTHING BELOW HERE
path_to_cli_config='~/.circleci/cli.yml'
circleci_root='https://circleci.com/'
api_root="${circleci_root}api/v2/"
cli_config_path="${HOME}/.circleci/cli.yml"

# branch="tryapi"

#********************
# FUNCTIONS
# *******************

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
    error "${1} is required, but you don't seem to have it. Aborting because this script won't work without ${1}."
  fi
  echo "${1} is required and present. Proceeding..."
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
  step "Your project_slug is set to ${project_slug}. You can change this in the file $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  vcs_slug=$(awk -F/ '{print $1}' <<< $project_slug)
  org_name=$(awk -F/ '{print $2}' <<< $project_slug)
  project_name=$(awk -F/ '{print $3}' <<< $project_slug)
}



post () {
  local url="${api_root}${1}"
  printf "HTTP POST ${url}\n\n" > /dev/tty

  curl -su ${circle_token}: -X POST \
       --header "Content-Type: application/json" \
       -d "$2"\
       "${url}"
}

get () {
  local url="${api_root}${1}"
  printf "HTTP GET ${url}\n\n" > /dev/tty
  curl -su ${circle_token}: \
       --header "Content-Type: application/json" \
       "${url}"
}

pretty_json () {
  # jq . <<< "${result}" | sed 's/^/  /'
  echo "\`\`\`"
  jq . <<< "${result}"
  echo "\`\`\`"
}

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
require_command awk
section 'SETUP SOME VARIABLES'
ensure_project_slug
set_token

#********************
# TRIGGER AND RETRIEVE PIPELINE
# *******************
section 'TRY TRIGGERING AND RETRIEVING A PIPELINE'
post_path="project/${project_slug}/pipeline"
step "Attemping to trigger a pipeline with a POST to ${post_path}"
params="{\"parameters\": ${parameter_map} }"
result=$(post $post_path "${params}")
pretty_json $result
pipeline_id=$(echo $result | jq -r .id)
step "Successfully created pipeline with ID $pipeline_id"
get_path="pipeline/${pipeline_id}"
step "GET pipeline by ID: /${get_path} - the raw payload is below"
result=$(get $get_path)
workflow_count=$(echo $result | jq -r '.workflows | length' )

pretty_json $result

#********************
# GET WORKFLOWS
# *******************
section 'GET THE WORKFLOWS FOR THE ABOVE PIPELINE'

# jq -r .workflows.ids[] <<<$result


step "You should now be able to see the ${workflow_count} workflow(s) for this pipeline here:"
workflow_url_for_project="${circleci_root}${vcs_slug}/${org_name}/workflows/${project_name}"
echo $workflow_url_for_project
echo ""
workflow_ids=($(echo $result | jq -r '.workflows[].id | @sh'))
#DUMB HACK TO STRIP SINGLE QUOTES THAT CAN LIKELY BE SOLVED MORE ELEGANTLY
workflow_ids=(${workflow_ids[@]//\'/})
step "Now let's loop over the ${workflow_count} workflow(s) and get info about each one"
declare -a running_workflows
for id in ${workflow_ids[@]}; do
  get_path="workflow/${id}"
  step "GET workflow by ID: /${get_path} - the raw payload is below"
  result=$(get $get_path)
  pretty_json $result
  status=$(echo $result | jq -r '.status')
  if [[ $status == "running" ]]; then
    echo "Still running, so add it to the list of workflows to poll down below..."
    running_workflows+=($id)
  else
    echo "Finished running with status: ${status}"
  fi
done
step "There's ${#running_workflows[@]} workflow(s) running. Below we loop through them, polling each one for a while to see if it will finish"

for i in "${!running_workflows[@]}"; do
  id=${running_workflows[i]}
  still_running=true
  maxloops=25
  loops=0
  wait="1s"

  get_path="workflow/${id}"
  step "Poll every ${wait} to GET workflow /${get_path}"
  echo "NOTE: If you prefer to see it in the UI visit:"
  echo "${circleci_root}workflow-run/${id}"
  printf "polling, please wait..."
  while [ $still_running ]; do
    ((loops+=1))
    result=$(get $get_path)
    status=$(echo $result | jq -r '.status')
    if [[ $status != "running" ]]; then
      still_running=false
      printf "Finished with status of ${status}!\n"
      echo "Now retrieve info on the jobs of this workflow"
      get_path="workflow/${id}/jobs"
      echo "GET workflow jobs: /${get_path}"
      result=$(get $get_path)
      pretty_json $result
      break
    else
      sleep $wait
      printf "."
      continue
    fi
    if [[ $loops == $maxloops ]]; then
      echo "Max loops of ${maxloops} has been reached, so stopping querying for this workflow."
      break
    fi
  done
done

#********************
# GET RECENT PIPELINES FOR THE PROJECT
# *******************
section 'GET RECENT PIPELINES'
get_path="project/${project_slug}/pipeline"
step "GET recent pipelines for project ${project_slug}  - The latest two from '.items' are below"
result=$(get $get_path)
echo $result | jq .items[0:2]


