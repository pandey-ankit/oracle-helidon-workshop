## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Create group for compartment and cloud shell
resource "oci_identity_group" "user_group" {
  name           = "devops-group${local.resource_name_random_suffix}"
  description    = "Group for users to be able to access all resources on created compartment and cloud shell"
  compartment_id = var.tenancy_ocid
}

# Create user-group membership if user_ocid is set
resource "oci_identity_user_group_membership" "user_group_membership" {
  count    = length(var.user_ocid) > 0 ? 1 : 0
  group_id = oci_identity_group.user_group.id
  user_id  = var.user_ocid
}
