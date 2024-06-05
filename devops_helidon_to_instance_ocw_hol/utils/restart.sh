#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

SCRIPT_DIR=$(dirname $0)
PUBLIC_IP=$(~/devops_helidon_to_instance_ocw_hol/main/get.sh public_ip)
GET_SH=${SCRIPT_DIR}/../main/get.sh

# Generate private key
${GET_SH} create_ssh_private_key
ssh -i private.key opc@${PUBLIC_IP} "sudo -u ocarun bash" < ${SCRIPT_DIR}/restart_on_server.sh
# remove private key
echo "Cleaning up ssh private.key"
rm -f private.key
