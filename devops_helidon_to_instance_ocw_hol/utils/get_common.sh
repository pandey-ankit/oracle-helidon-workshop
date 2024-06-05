#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Extracts resource value from terraform state
get_resource_value() {
  parse_tf_output $1
}

# Parses resource from terraform state output
parse_tf_output() {
  local resource=$(jq -r '.outputs.'"${1}"'.value' ${TERRAFORM_TFSTATE})
  evaluate_parsed_resource ${resource}
}

# Evaluate if parsed resource is empty or not
evaluate_parsed_resource() {
  if [[ ! -z "${1}" && "${1}" != "null" ]]; then
    echo -n ${1}
  else
    echo -n "Requested oci resource does not exist"
  fi
}

print_command_detail() {
  local key=${1}
  local description=${2}
  local key_left_justified_size=${3}
  printf '   %-'"${key_left_justified_size}"'s' ${key}
  echo ${description}
}

print_resource() {
  local key=${1}
  local description=${2}
  local key_left_justified_size=${3}
  printf '%-'"${key_left_justified_size}"'s: ' ${key}
  echo ${description}
}

if ! test -f ${TERRAFORM_TFSTATE}; then
  echo "Error: Terraform state (\"${TERRAFORM_TFSTATE}\") does not exist which means the oci resource(s) have not been provisioned yet"
  exit 1
fi


