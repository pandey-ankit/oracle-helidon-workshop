## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "compartment_ocid" {
  default = ""
}
variable "home_region" {
  default = ""
}
variable "region" {
  default = ""
}

# Best to set values for below variables in terraform.tfvars under the following conditions:
# 1. If using user principal authentication.
# 2. If user needs additional policy to access the created compartment and add cloud shell, which in this
#    scenario, needs only "user_ocid" to be set up.
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

# Allows provisioned compute instance to be ssh'd with corresponding private key. If empty, a public/private ssh key pair
# will be generated and private key can be extracted from the TF state.
variable "ssh_public_key" {
  default = ""
}

variable "availablity_domain_name" {
  default = ""
}
variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "Subnet-CIDR" {
  default = "10.0.0.0/24"
}

variable "instance_shape" {
  description = "Instance Shape"
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  default = 1
}

variable "instance_shape_config_memory_in_gbs" {
  default = 16
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8"
}

variable "project_logging_config_retention_period_in_days" {
  default = 30
}

variable "project_description" {
  default = "DevOps Project for Instance Group deployment of a Helidon Application"
}
