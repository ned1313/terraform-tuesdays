# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the global scope
resource "boundary_role" "global_anon_listing" {
  scope_id = boundary_scope.global.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the org level scope
resource "boundary_role" "org_anon_listing" {
  scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

# Creates a role in the global scope that's granting administrative access to 
# resources in the org scope for all backend users
resource "boundary_role" "org_admin" {
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = concat(
    [for user in boundary_user.backend : user.id],
    [for user in boundary_user.frontend : user.id],
  )
}

# Adds a read-only role in the global scope granting read-only access
# to all resources within the org scope and adds principals from the 
# leadership team to the role
resource "boundary_role" "org_readonly" {
  name        = "readonly"
  description = "Read-only role"
  principal_ids = [
    boundary_group.leadership.id
  ]
  grant_strings = [
    "id=*;type=*;actions=read"
  ]
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
}

# Adds an org-level role granting administrative permissions within the core_infra project
resource "boundary_role" "project_admin" {
  name           = "core_infra_admin"
  description    = "Administrator role for core infra"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.core_infra.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = concat(
    [for user in boundary_user.backend : user.id],
    [for user in boundary_user.frontend : user.id],
  )
}
