#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

SCRIPT_DIR=$(dirname $0)
export TERRAFORM_TFSTATE=${SCRIPT_DIR}/terraform.tfstate
source ${SCRIPT_DIR}/../utils/get_common.sh

# Command Choices:
COMPARTMENT_ID_COMMAND=compartment_id
CODE_REPO_NAME_COMMAND=code_repo_https_url
BUCKET_NAME_COMMAND=bucket_name
APP_LOG_ID_COMMAND=app_log_id
PUBLIC_IP_COMMAND=public_ip
ALL_COMMAND=all
CREATE_SSH_PRIVATE_KEY_COMMAND=create_ssh_private_key

get_compartment_id() {
  local compartment_id=$(jq -r '.resources[] | select(.type == "oci_core_instance").instances[].attributes | select(.display_name == "instance-helidon-ocw-hol") | .compartment_id' ${TERRAFORM_TFSTATE})
  evaluate_parsed_resource ${compartment_id}
  echo
}

get_code_repo_name() {
  get_resource_value application_code_repository_https_url
  echo
}

get_bucket_name() {
  get_resource_value application_bucket_name
  echo
}

get_app_log_id() {
  get_resource_value application_log_id
  echo
}

get_public_ip() {
  get_resource_value deployment_instance_public_ip
  echo
}

# Extract ssh private key value from output, save in private.key and change file mode to read-only
create_ssh_private_key() {
  rm -rf private.key
  local private_key=$(jq -r '.outputs.generated_ssh_private_key.value' ${TERRAFORM_TFSTATE})
  if [[ ! -z "${private_key}" && "${private_key}" != "null" ]]; then
    echo -n "${private_key}" > private.key
    chmod go-rw private.key
    echo -n "Created private.key and can be used to ssh to the deployment instance by running this command: \"ssh -i private.key opc@"
    get_resource_value deployment_instance_public_ip
    echo "\""
  else
    echo "Private key does not exist"
  fi
}

# Display usage information for this tool.
display_help()
{
  local left_justified_size=24
  echo "Usage: $(basename "$0") {${COMPARTMENT_ID_COMMAND}|${CODE_REPO_NAME_COMMAND}|${BUCKET_NAME_COMMAND}|${APP_LOG_ID_COMMAND}|${PUBLIC_IP_COMMAND}|${ALL_COMMAND}|${CREATE_SSH_PRIVATE_KEY_COMMAND}}"
  echo
  print_command_detail ${COMPARTMENT_ID_COMMAND} "displays compartment id" ${left_justified_size}
  print_command_detail ${CODE_REPO_NAME_COMMAND} "displays application code repository name" ${left_justified_size}

  print_command_detail ${BUCKET_NAME_COMMAND} "displays application application bucket name" ${left_justified_size}
  print_command_detail ${APP_LOG_ID_COMMAND} "displays application custom log id" ${left_justified_size}
  print_command_detail ${PUBLIC_IP_COMMAND} "displays the public ip of the compute host instance used for deployment" ${left_justified_size}
  print_command_detail ${ALL_COMMAND} "displays ${COMPARTMENT_ID_COMMAND}, ${CODE_REPO_NAME_COMMAND}, ${BUCKET_NAME_COMMAND}, ${APP_LOG_ID_COMMAND}, ${PUBLIC_IP_COMMAND}" ${left_justified_size}
  echo "   ---"
  print_command_detail ${CREATE_SSH_PRIVATE_KEY_COMMAND} "creates private.key that can be used to ssh to the compute instance" ${left_justified_size}
  echo
}

# Main routine
case "$1" in
  ${COMPARTMENT_ID_COMMAND})
    get_compartment_id
    ;;
  ${CODE_REPO_NAME_COMMAND})
    get_code_repo_name
    ;;
  ${BUCKET_NAME_COMMAND})
    get_bucket_name
    ;;
  ${APP_LOG_ID_COMMAND})
    get_app_log_id
    ;;
  ${PUBLIC_IP_COMMAND})
    get_public_ip
    ;;
  ${CREATE_SSH_PRIVATE_KEY_COMMAND})
    create_ssh_private_key
    ;;
  ${ALL_COMMAND})
    left_justified_size=19
    print_resource ${COMPARTMENT_ID_COMMAND} "$(get_compartment_id)" ${left_justified_size}
    print_resource ${CODE_REPO_NAME_COMMAND} "$(get_code_repo_name)" ${left_justified_size}
    print_resource ${BUCKET_NAME_COMMAND} "$(get_bucket_name)" ${left_justified_size}
    print_resource ${APP_LOG_ID_COMMAND} "$(get_app_log_id)" ${left_justified_size}
    print_resource ${PUBLIC_IP_COMMAND} "$(get_public_ip)" ${left_justified_size}
    ;;
  *)
    display_help
    ;;
esac
