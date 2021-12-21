# Create workspaces
resource "tfe_workspace" "workspaces" {
  for_each     = var.workspaces
  name         = each.key
  organization = var.organization
  tag_names    = each.value
}

# Create teams
resource "tfe_team" "teams" {
  for_each     = toset(keys(var.teams))
  name         = each.value
  organization = var.organization
  visibility   = "organization"
}

# Get a list of workspaces for each tag
locals {
  workspace_tags = {
    for tag, permissions in var.tags : tag => [
      for workspace, tags in var.workspaces : workspace if contains(tags, tag)
    ]
  }

  tags_list = flatten([
    for tag, permissions in var.tags : [
      for team, permission in permissions : {
        tag_name     = tag
        team_name    = team
        access_level = permission
      }
    ]
  ])

  workspace_access = distinct(flatten([
    for access in local.tags_list : [
      for workspace, tags in var.workspaces : {
        workspace_name = workspace
        team_name      = access["team_name"]
        access_level   = access["access_level"]
      } if contains(tags, access["tag_name"])
    ]
  ]))
}

# Configure workspace access for teams
resource "tfe_team_access" "access" {
  count        = length(local.workspace_access)
  access       = local.workspace_access[count.index].access_level
  team_id      = tfe_team.teams[local.workspace_access[count.index].team_name].id
  workspace_id = tfe_workspace.workspaces[local.workspace_access[count.index].workspace_name].id
}