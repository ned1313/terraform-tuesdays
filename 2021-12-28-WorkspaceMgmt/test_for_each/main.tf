locals {
  org_data = jsondecode(file("workspace_configs.json"))

  variable_set = try(local.org_data.variable_set,[])

  workspaces = try(local.org_data.workspaces, [])

  normalized_workspaces = local.workspaces != [] ? [ for workspace in local.workspaces : {
      name = try(workspace["name"], "missing_name")
      description = try(workspace["description"],"")
      teams = try(workspace["teams"],[])
      terraform_version = try(workspace["terraform_version"],null)
      tag_names = try(workspace["tag_names"],[])
      vcs_repo = try(workspace["vcs_repo"],{})
  }] : []
}

resource "local_file" "variable_set" {
    for_each = toset(local.variable_set)
    content = "null"
    filename = "${each.key}.txt"
}

resource "local_file" "workspaces" {
  for_each = { for workspace in local.workspaces : workspace["name"] => workspace }
  content = try(each.value["missing_key"], "nothing")
  filename = "${each.key}.txt"
}