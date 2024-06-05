## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Create all resources required by the Helidon application
resource "oci_logging_log_group" "application_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "app-log-group${local.resource_name_suffix}"
}

resource "oci_logging_log" "application_log" {
  display_name = "app-log${local.resource_name_suffix}"
  log_group_id = oci_logging_log_group.application_log_group.id
  log_type     = "CUSTOM"
}

# Create Artifact Repository where the built application and deployment manifest will be uploaded
resource "oci_objectstorage_bucket" "application_bucket" {
  compartment_id = var.compartment_ocid
  name           = "app-bucket${local.resource_name_random_suffix}"
  namespace      = data.oci_objectstorage_namespace.object_storage_namespace.namespace
}
