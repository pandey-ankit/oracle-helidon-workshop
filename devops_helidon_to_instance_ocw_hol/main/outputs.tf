## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Output private key used for ssh connection to the provisioned instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

# Output compute instance public ip
output "deployment_instance_public_ip" {
  value = oci_core_instance.compute_instance.public_ip
}

# Output code repository https url
output "application_code_repository_https_url" {
  value = oci_devops_repository.devops_repo.http_url
}

# Output object storage application bucket
output "application_bucket_name" {
  value = oci_objectstorage_bucket.application_bucket.name
}

# Output object storage application bucket
output "application_log_id" {
  value = oci_logging_log.application_log.id
}

