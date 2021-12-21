variable "organization" {
  type        = string
  description = "(Required) Name of organization to use for resource management."
}

variable "org_email" {
  type        = string
  description = "(Required) Email of owner for organization."
}

variable "workspaces" {
  type = map(object({
    read_access  = list(string)
    write_access = list(string)
    admin_access = list(string)
    tags         = list(string)
  }))
  description = "(Required) A map of workspaces to create. The value is a list of tags to apply to the workspace."
}

variable "teams" {
  type        = map(list(string))
  description = "(Required) A map of teams to create. The value is a list of usernames to associate with the Team."
}