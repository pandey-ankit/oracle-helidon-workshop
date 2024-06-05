#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

ARTIFACT_REPO_NAME=artifact-repo-helidon-ocw-hol
BUCKET_NAME=$($(dirname $0)/get.sh bucket_name)

resources=$(jq -r '.resources[] | select(.type == "oci_artifacts_repository").instances[].attributes | select(.display_name == "'"${ARTIFACT_REPO_NAME}"'") | .compartment_id,.id' terraform.tfstate)
readarray -t resources <<<"$resources"
COMPARTMENT_ID=${resources[0]}
ARTIFACT_REPO_ID=${resources[1]}

# All artifacts in the repository should be deleted
artifact_ids=$(oci artifacts generic artifact list --compartment-id ${COMPARTMENT_ID} --repository-id ${ARTIFACT_REPO_ID} --all --query 'data.items[*].id' --raw-output | jq -r '.[]')
echo "Deleting all artifacts from '"${ARTIFACT_REPO_NAME}"'"
i=0
for artifact_id in ${artifact_ids[@]} ; do
  oci artifacts generic artifact delete --artifact-id ${artifact_id} --force
  ((i=i+1))
done
echo "Deleted $i artifacts"
echo

# All objects in the bucket should be deleted
object_names=$(oci os object list --bucket-name ${BUCKET_NAME} --all --query 'data[*].name' --raw-output | jq -r '.[]')
echo "Deleting all objects from '"${BUCKET_NAME}"'"
i=0
for object_name in ${object_names[@]} ; do
  oci os object delete --bucket-name ${BUCKET_NAME} --object-name ${object_name} --force
  ((i=i+1))
done
echo "Deleted $i objects"
echo

echo "Begin Terraform destroy..."
echo
terraform destroy -auto-approve
