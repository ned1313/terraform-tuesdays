variable "ado_org_service_url" {
    type = string
    description = "Org service url for Azure DevOps"
}

variable "ado_github_repo" {
    type = string
    description = "Name of the repository in the format <GitHub Org>/<RepoName>"
    default = "ned1313/terraform-tuesdays"
}

variable "ado_pipeline_yaml_path_1" {
    type = string
    description = "Path to the yaml for the first pipeline"
    default = "2021-05-11-ADO/vnet/azure-pipelines.yaml"
}

variable "prefix" {
    type = string 
    description = "Naming prefix for resources"
    default = "tacos"
}

variable "ado_github_pat" {
    type = string
    description = "Personal authentication token for GitHub repo"
    sensitive = true
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

locals {
    ado_project_name = "${var.prefix}-project-${random_integer.suffix.result}"
    ado_project_description = "Project for ${var.prefix}"
    ado_project_visibility = "private"
    ado_pipeline_name_1 = "${var.prefix}-pipeline-1"
}