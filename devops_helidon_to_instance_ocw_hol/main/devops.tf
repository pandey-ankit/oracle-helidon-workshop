## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Create OCI Notification
resource "oci_ons_notification_topic" "devops_notification_topic" {
  compartment_id = var.compartment_ocid
  name           = "devops-topic${local.resource_name_random_suffix}"
}

# Create devops project
resource "oci_devops_project" "devops_project" {
  compartment_id = var.compartment_ocid
  name           = "devops-project${local.resource_name_random_suffix}"
  notification_config {
    topic_id = oci_ons_notification_topic.devops_notification_topic.id
  }
  description = var.project_description
}

# Create OCI Code Repository
resource "oci_devops_repository" "devops_repo" {
  name            = local.application_repo_name
  description     = "Will host Helidon OCI MP template app generated via the archetype tool"
  project_id      = oci_devops_project.devops_project.id
  repository_type = "HOSTED"
  default_branch  = "main"
}

##### Start of Build Pipeline Code #####

# Create build pipeline
resource "oci_devops_build_pipeline" "devops_build_pipeline" {
  project_id   = oci_devops_project.devops_project.id
  display_name = "devops-build-pipeline${local.resource_name_suffix}"
  description  = "Build Pipeline"
}

# 1st build pipeline stage - Managed Build
resource "oci_devops_build_pipeline_stage" "devops_build_stage" {
  build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline.devops_build_pipeline.id
    }
  }
  display_name              = "devops-build-stage${local.resource_name_suffix}"
  description               = "1st build pipeline stage - Managed Build"
  build_pipeline_stage_type = "BUILD"
  build_runner_shape_config {
    build_runner_type = "DEFAULT"
  }
  image                = "OL7_X86_64_STANDARD_10"
  build_spec_file      = "" # defaults to build_spec.yaml
  primary_build_source = oci_devops_repository.devops_repo.name
  build_source_collection {
    items {
      connection_type = "DEVOPS_CODE_REPOSITORY"
      repository_id   = oci_devops_repository.devops_repo.id
      name            = oci_devops_repository.devops_repo.name
      repository_url  = oci_devops_repository.devops_repo.http_url
      branch          = "main"
    }
  }
  stage_execution_timeout_in_seconds = "36000"
}

# 2nd build pipeline stage - Upload Artifact
resource "oci_devops_build_pipeline_stage" "devops_upload_stage" {
  build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline_stage.devops_build_stage.id
    }
  }
  display_name              = "devops-upload-stage${local.resource_name_suffix}"
  description               = "2nd build pipeline stage - Upload Artifact"
  build_pipeline_stage_type = "DELIVER_ARTIFACT"
  deliver_artifact_collection {
    items {
      artifact_id   = oci_devops_deploy_artifact.devops_application_artifact.id
      artifact_name = "app_distribution"
    }
    items {
      artifact_id   = oci_devops_deploy_artifact.devops_deployment_spec_artifact.id
      artifact_name = "deployment_spec"
    }
  }
}

# 3rd build pipeline stage - Trigger Deployment
resource "oci_devops_build_pipeline_stage" "devops_trigger_deployment_stage" {
  build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline_stage.devops_upload_stage.id
    }
  }
  display_name                   = "devops-trigger-deployment-stage${local.resource_name_suffix}"
  description                    = "3rd build pipeline stage - Trigger Deployment"
  build_pipeline_stage_type      = "TRIGGER_DEPLOYMENT_PIPELINE"
  deploy_pipeline_id             = oci_devops_deploy_pipeline.devops_deploy_pipeline.id
  is_pass_all_parameters_enabled = true
}

##### End of Build Pipeline Code #####

##### Start of Deployment Pipeline Code #####

# Create deployment pipeline and pass in the Artifact Repository OCID as a parameter
resource "oci_devops_deploy_pipeline" "devops_deploy_pipeline" {
  project_id   = oci_devops_project.devops_project.id
  description  = "Deploy Pipleline"
  display_name = "devops-deployment-pipeline${local.resource_name_suffix}"
  deploy_pipeline_parameters {
    # Insert the Artifact Repository ID as a parameter so it can be used to download the App
    items {
      name          = "ARTIFACT_REPO_OCID"
      description   = "Artifact Repository OCID used to download the application"
      default_value = oci_artifacts_repository.artifact_repo.id
    }
  }
}

# Create a deployment stage in the deployment pipeline targeting compute instance as the deployment destination
resource "oci_devops_deploy_stage" "devops_deploy_stage" {
  deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_pipeline.devops_deploy_pipeline.id
    }
  }
  deploy_stage_type                            = "COMPUTE_INSTANCE_GROUP_ROLLING_DEPLOYMENT"
  display_name                                 = "devops-deployment-stage${local.resource_name_suffix}"
  description                                  = "Deployment Pipeline Stage that will set a compute instance as the target platform"
  compute_instance_group_deploy_environment_id = oci_devops_deploy_environment.devops_deploy_environment.id
  deployment_spec_deploy_artifact_id           = oci_devops_deploy_artifact.devops_deployment_spec_artifact.id
  rollout_policy {
    batch_count            = "5"
    batch_delay_in_seconds = "10"
    policy_type            = "COMPUTE_INSTANCE_GROUP_LINEAR_ROLLOUT_POLICY_BY_COUNT"
  }
  rollback_policy {
    policy_type = "AUTOMATED_STAGE_ROLLBACK_POLICY"
  }
}

# Create environment to set compute instance as target platform for deployment pipeline
resource "oci_devops_deploy_environment" "devops_deploy_environment" {
  project_id              = oci_devops_project.devops_project.id
  display_name            = "devops-instance-group-environment${local.resource_name_suffix}"
  description             = "Sets a compute instance as the target platform for deployment pipeline"
  deploy_environment_type = "COMPUTE_INSTANCE_GROUP"
  compute_instance_group_selectors {
    items {
      compute_instance_ids = [oci_core_instance.compute_instance.id]
      selector_type        = "INSTANCE_IDS"
    }
  }
}

##### End of Deployment Pipeline Code #####

#### Start of deploy artifacts code which will be used by the Upload Artifact Stage and the Deploy Instance Group Stage #####

# Create deployment spec artifact to use. The deployment spec will be renamed to "deployment_manifest.yaml"
# when uploaded to Artifact Repository.
resource "oci_devops_deploy_artifact" "devops_deployment_spec_artifact" {
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_type       = "DEPLOYMENT_SPEC"
  project_id                 = oci_devops_project.devops_project.id
  display_name               = "devops-deployment-spec-artifact${local.resource_name_suffix}"
  deploy_artifact_source {
    deploy_artifact_path        = "deployment_manifest.yaml"
    deploy_artifact_source_type = "GENERIC_ARTIFACT"
    deploy_artifact_version     = "$${BUILDRUN_HASH}"
    repository_id               = oci_artifacts_repository.artifact_repo.id
  }
}

# Create application artifact to use. The generic file which will correspond to the Helidon App
# will be renamed to "helidon-oci-mp.tgz" when uploaded to Artifact Repository.
resource "oci_devops_deploy_artifact" "devops_application_artifact" {
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_type       = "GENERIC_FILE"
  project_id                 = oci_devops_project.devops_project.id
  display_name               = "devops-application-artifact${local.resource_name_suffix}"
  deploy_artifact_source {
    deploy_artifact_path        = "helidon-oci-mp.tgz"
    deploy_artifact_source_type = "GENERIC_ARTIFACT"
    deploy_artifact_version     = "$${BUILDRUN_HASH}"
    repository_id               = oci_artifacts_repository.artifact_repo.id
  }
}

#### End of deploy artifacts code #####

# Create a trigger to start the pipeline if code repository push event occurs
resource "oci_devops_trigger" "devops_trigger" {
  project_id     = oci_devops_project.devops_project.id
  display_name   = "devops-trigger${local.resource_name_suffix}"
  description    = "Will trigger start of pipeline when push event on the code repository takes place"
  trigger_source = "DEVOPS_CODE_REPOSITORY"
  repository_id  = oci_devops_repository.devops_repo.id
  actions {
    build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline.id
    type              = "TRIGGER_BUILD_PIPELINE"
    filter {
      trigger_source = "DEVOPS_CODE_REPOSITORY"
      events         = ["PUSH"]
      include {
        head_ref = "main"
      }
    }
  }
}

# Create log group that will serve as the logical container for the devops log
resource "oci_logging_log_group" "devops_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "devops-log-group${local.resource_name_suffix}"
}

# Create log to store devops logging
resource "oci_logging_log" "devops_log" {
  display_name = "devops-log${local.resource_name_suffix}"
  log_group_id = oci_logging_log_group.devops_log_group.id
  log_type     = "SERVICE"
  configuration {
    source {
      category    = "all"
      resource    = oci_devops_project.devops_project.id
      service     = "devops"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }
  is_enabled         = true
  retention_duration = var.project_logging_config_retention_period_in_days
}
