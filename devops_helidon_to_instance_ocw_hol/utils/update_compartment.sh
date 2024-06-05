#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

set -e
SCRIPT_DIR=$(dirname $0)
INIT_DIR=${SCRIPT_DIR}/../init

INIT_TERRAFORM_TFSTATE=${INIT_DIR}/terraform.tfstate
if ! test -f ${INIT_TERRAFORM_TFSTATE}; then
  echo "Error: Terraform state (\"${INIT_TERRAFORM_TFSTATE}\") does not exist"
  exit 1
fi

COMPARTMENT_ID=$(${INIT_DIR}/get.sh compartment_id)
if [[ "${COMPARTMENT_ID}" == *"Requested oci resource does not exist"* ]]; then
  echo ${COMPARTMENT_ID}
  exit 1
fi

TERRAFORM_TFVARS=${SCRIPT_DIR}/../terraform.tfvars
sed -i -e 's/.*compartment_ocid.*/compartment_ocid = '"\"${COMPARTMENT_ID}\""'/' ${TERRAFORM_TFVARS}
echo "compartment_ocid in ${TERRAFORM_TFVARS} was updated"
