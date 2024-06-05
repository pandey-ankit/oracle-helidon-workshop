## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_compartment" "devops_demo_compartment" {
  name           = "devops-compartment${local.resource_name_random_suffix}"
  description    = "Devops with Helidon hands-on-lab compartment"
  compartment_id = var.tenancy_ocid
  enable_delete  = true
}

