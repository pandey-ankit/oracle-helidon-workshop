#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

SCRIPT_DIR=$(dirname $0)
export TERRAFORM_TFSTATE=${SCRIPT_DIR}/terraform.tfstate
source ${SCRIPT_DIR}/../utils/get_common.sh

# Command Choices:
COMPARTMENT_ID_COMMAND=compartment_id
COMPARTMENT_NAME_COMMAND=compartment_name
ALL_COMMAND=all

get_compartment_id() {
  get_resource_value ${COMPARTMENT_ID_COMMAND}
  echo
}

get_compartment_name() {
  get_resource_value ${COMPARTMENT_NAME_COMMAND}
  echo
}

# Display usage information for this tool.
display_help()
{
  local left_justified_size=9
  echo "Usage: $(basename "$0") {${COMPARTMENT_ID_COMMAND}|${COMPARTMENT_NAME_COMMAND}|${ALL_COMMAND}}"
  echo
  print_command_detail ${COMPARTMENT_ID_COMMAND} "displays compartment id" ${left_justified_size}
  print_command_detail ${COMPARTMENT_NAME_COMMAND} "displays compartment name" ${left_justified_size}
  print_command_detail ${ALL_COMMAND} "displays ${COMPARTMENT_ID_COMMAND}, ${CCOMPARTMENT_NAME_COMMAND}" ${left_justified_size}
  echo
}

# Main routine
case "$1" in
  ${COMPARTMENT_ID_COMMAND})
    get_compartment_id
    ;;
  ${COMPARTMENT_NAME_COMMAND})
    get_compartment_name
    ;;
  ${ALL_COMMAND})
    left_justified_size=16
    print_resource ${COMPARTMENT_ID_COMMAND} "$(get_compartment_id)" ${left_justified_size}
    print_resource ${COMPARTMENT_NAME_COMMAND} "$(get_compartment_name)" ${left_justified_size}
    ;;
  *)
    display_help
    ;;
esac
