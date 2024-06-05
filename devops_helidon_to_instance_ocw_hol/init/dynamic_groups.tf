## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Create group, user and polcies for devops service
resource "oci_identity_dynamic_group" "devops_dynamic_group" {
  name           = "devops-dynamic-group${local.resource_name_random_suffix}"
  description    = "DevOps pipeline dynamic group"
  compartment_id = var.tenancy_ocid
  matching_rule = format("Any {%s, %s, %s}",
    "ALL {resource.type = 'devopsbuildpipeline', resource.compartment.id = '${oci_identity_compartment.devops_demo_compartment.id}'}",
    "ALL {resource.type = 'devopsdeploypipeline', resource.compartment.id = '${oci_identity_compartment.devops_demo_compartment.id}'}",
    "ALL {resource.type = 'devopsrepository', resource.compartment.id = '${oci_identity_compartment.devops_demo_compartment.id}'}"
  )
}

resource "oci_identity_dynamic_group" "instance_dynamic_group" {
  name           = "instance-dynamic-group${local.resource_name_random_suffix}"
  description    = "Compute instance dynamic group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ALL {instance.compartment.id = '${oci_identity_compartment.devops_demo_compartment.id}'}"
}
