## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  region = var.home_region != "" ? var.home_region : var.region
}

terraform {
  required_version = ">= 0.14"
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = local.region

  # Uncomment below parameters and set the corresponding values in terraform.tfvars if using User Principal Authentication
  # user_ocid        = var.user_ocid
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
}
