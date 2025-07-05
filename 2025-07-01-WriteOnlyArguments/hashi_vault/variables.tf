variable "burrito_recipe" {
  description = "Secret information for the burrito recipe"
  type = object({
    ingredients  = string
    instructions = string
    chef_notes   = optional(string, "")
  })

  sensitive = true
  ephemeral = true
}

variable "burrito_recipe_version" {
  description = "Version of the burrito recipe secret"
  type        = number

  validation {
    condition     = var.burrito_recipe_version > 0 && var.burrito_recipe_version == floor(var.burrito_recipe_version)
    error_message = "The burrito_recipe_version must be a non-negative integer."
  }

}

variable "secret_mount_path" {
  description = "Mount path for the Vault KV v2 secret engine"
  type        = string
  default     = "secret"
}
