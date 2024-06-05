## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Tenancy
tenancy_ocid = "ocid1.tenancy.oc1.."

# Region - Set home_region variable only if it is different from region. Only used when running scripts under init.
#          If home_region is not set, region variable will also be considered as the home_region in init.
# home_region = ""
region = "us-ashburn-1"

# Compartment - Will only be used in scripts under main. Fill this up with the compartment id created in init or
#               an already existing compartment that you wish to use for this demo.
compartment_ocid = "ocid1.compartment.oc1.."

# Set values for below variables only under the following conditions:
# 1. If using user principal authentication. Set the proper user credentials and uncomment corresponding provider
#    parameters in providers.tf.
# 2. If user needs additional policy to access the created compartment and cloud shell, which in this scenario, needs
#    only "user_ocid" to be set up.
#
user_ocid        = "ocid1.user.oc1.."
# fingerprint      = "1c.."
# private_key_path = "~/.oci/oci_api_key.pem"

# Shape of the instance
instance_shape   = "VM.Standard.E3.Flex"
