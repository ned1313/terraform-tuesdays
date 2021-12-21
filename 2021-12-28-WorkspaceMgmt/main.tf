# Create an organization
resource "tfe_organization" "org" {
  name  = var.organization
  email = var.org_email # Define in variables for workspace
}

# Create workspaces
resource "tfe_workspace" "workspaces" {
  for_each     = var.workspaces
  name         = each.key
  organization = tfe_organization.org.id
  tag_names    = each.value["tags"]
}

# Create teams
resource "tfe_team" "teams" {
  for_each     = toset(keys(var.teams))
  name         = each.value
  organization = tfe_organization.org.id
  visibility   = "organization"
}

# Get a list of workspaces for each tag
locals {
  workspace_read_access = flatten([
    for workspace, settings in var.workspaces : [
      for read_entry in settings["read_access"] : {
        workspace_name = workspace
        team_name      = read_entry
      } if length(settings["read_access"]) > 0
    ]
  ])

  workspace_write_access = flatten([
    for workspace, settings in var.workspaces : [
      for write_entry in settings["write_access"] : {
        workspace_name = workspace
        team_name      = write_entry
      } if length(settings["write_access"]) > 0
    ]
  ])

  workspace_admin_access = flatten([
    for workspace, settings in var.workspaces : [
      for admin_entry in settings["admin_access"] : {
        workspace_name = workspace
        team_name      = admin_entry
      } if length(settings["admin_access"]) > 0
    ]
  ])

}

# Configure workspace access for teams
resource "tfe_team_access" "read_access" {
  count        = length(local.workspace_read_access)
  access       = "read"
  team_id      = tfe_team.teams[local.workspace_read_access[count.index].team_name].id
  workspace_id = tfe_workspace.workspaces[local.workspace_read_access[count.index].workspace_name].id
}

resource "tfe_team_access" "write_access" {
  count        = length(local.workspace_write_access)
  access       = "write"
  team_id      = tfe_team.teams[local.workspace_write_access[count.index].team_name].id
  workspace_id = tfe_workspace.workspaces[local.workspace_write_access[count.index].workspace_name].id
}

resource "tfe_team_access" "admin_access" {
  count        = length(local.workspace_admin_access)
  access       = "admin"
  team_id      = tfe_team.teams[local.workspace_admin_access[count.index].team_name].id
  workspace_id = tfe_workspace.workspaces[local.workspace_admin_access[count.index].workspace_name].id
}