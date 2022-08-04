variable "identity_name" {
  type        = string
  description = "(Required) Name of application and service principal."
}

variable "repository_name" {
  type        = string
  description = "(Required) Name of the repository in the form (org | user)/repository"

  validation {
    condition     = can(regex("[a-zA-Z][a-zA-Z0-9-]*/[a-zA-Z0-9][a-zA-Z0-9_\\-\\.]*", var.repository_name))
    error_message = "Repository name must be in the form organization/repository or username/repository."
  }
}

variable "entity_type" {
  type        = string
  description = "(Required) Type of entity for federation. Can be environment, ref, pull-request, tag"

  validation {
    condition     = contains(["environment", "ref", "pull-request"], var.entity_type)
    error_message = "The entity_type must be one of the following: environment, ref, pull-request."
  }
}

variable "environment_name" {
  type        = string
  description = "(Optional) Name of environment entity. Required if entity_type is environment."
  default     = null
}

variable "ref_branch" {
  type        = string
  description = "(Optional) Name of branch to use with ref entity. Required if entity_type is ref and branch is the target."
  default     = null
}

variable "ref_tag" {
  type        = string
  description = "(Optional) Name of tag to use with ref entity. Required if entity_type is ref and tag is the target."
  default     = null
}

variable "owner_id" {
  type        = string
  description = "(Optional) Object ID of owner to be assigned to service principal. Assigned to current user if not set."
  default     = null
}
