locals {
  appname        = "azapi-ephemeral-demo"
  default_suffix = "${local.appname}-${var.env_code}"

  # optional computed short name
  # this assume two letters for the resource type, three for the location, and three for the environment code (= 24 chars max)
  # short_appname        = substr(replace(local.appname, "-", ""), 0, 16) 
  # default_short_suffix = "${local.short_appname}${var.env_code}"

  # add resource names here, using CAF-aligned naming conventions
  resource_group_name = "rg-${local.default_suffix}"

  # tflint-ignore: terraform_unused_declarations
  default_tags = merge(
    var.default_tags,
    tomap({
      "Environment"  = var.env_code
      "LocationCode" = var.short_location_code
    })
  )
}