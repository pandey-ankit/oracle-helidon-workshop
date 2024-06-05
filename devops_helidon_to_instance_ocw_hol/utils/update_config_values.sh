#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

set -e

DEFAULT_PROJECT_PATH=~/oci-mp
read -p "Enter the Helidon MP project's root directory (default: ${DEFAULT_PROJECT_PATH}): " PROJECT_PATH
# Use eval to expand ~ if it is part of the input
PROJECT_PATH=$(eval echo -n ${PROJECT_PATH:-${DEFAULT_PROJECT_PATH}})
echo $PROJECT_PATH

GET_SH=$(dirname $0)/../main/get.sh
COMPARTMENT_ID=$(${GET_SH} compartment_id)
APPLICATION_LOG_ID=$(${GET_SH} app_log_id)

APPLICATION_YAML=${PROJECT_PATH}/server/src/main/resources/application.yaml
sed -i 's/compartmentId: <your monitoring compartment id>/compartmentId: '"${COMPARTMENT_ID}"'/' ${APPLICATION_YAML}
sed -i 's/namespace: <your monitoring namespace e.g. helidon_oci>/namespace: helidon_metrics/' ${APPLICATION_YAML}
echo "Properties compartmentId and namespace under ocimetrics in ${APPLICATION_YAML} were updated"

MICROPROFILE_CONFIG_PROFILE=${PROJECT_PATH}/server/src/main/resources/META-INF/microprofile-config.properties
sed -i 's/oci.monitoring.compartmentId=<your monitoring compartment id>/oci.monitoring.compartmentId='"${COMPARTMENT_ID}"'/' ${MICROPROFILE_CONFIG_PROFILE}
sed -i 's/oci.monitoring.namespace=<your monitoring namespace e.g. helidon_oci>/oci.monitoring.namespace=helidon_application/' ${MICROPROFILE_CONFIG_PROFILE}
sed -i 's/oci.logging.id=<your oci custom log id>/oci.logging.id='"${APPLICATION_LOG_ID}"'/' ${MICROPROFILE_CONFIG_PROFILE}
echo "Properties oci.monitoring.compartmentId, oci.monitoring.namespace and oci.logging.id in ${MICROPROFILE_CONFIG_PROFILE} were updated"

set +e
APPLICATION_BUCKET_NAME_PARAMETER=oci.bucket.name
grep -q ${APPLICATION_BUCKET_NAME_PARAMETER} ${MICROPROFILE_CONFIG_PROFILE}
if [ $? -ne 0 ]; then
  APPLICATION_BUCKET_NAME_VALUE=$(${GET_SH} bucket_name)
  echo -e "\n# OCI Bucket Name\n${APPLICATION_BUCKET_NAME_PARAMETER}=${APPLICATION_BUCKET_NAME_VALUE}" >> ${MICROPROFILE_CONFIG_PROFILE}
  echo "Property ${APPLICATION_BUCKET_NAME_PARAMETER} was added in ${MICROPROFILE_CONFIG_PROFILE}"
fi
