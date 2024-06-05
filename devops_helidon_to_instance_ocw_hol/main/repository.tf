## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Create Artifact Repository where built applications will be uploaded
resource "oci_artifacts_repository" "artifact_repo" {
  compartment_id  = var.compartment_ocid
  is_immutable    = true
  repository_type = "GENERIC"
  display_name    = "artifact-repo${local.resource_name_suffix}"
}
