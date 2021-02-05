resource "boundary_user" "backend" {
  for_each    = var.backend_team
  name        = each.key
  description = "Backend user: ${each.key}"
  account_ids = [boundary_account.backend_user_acct[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_user" "frontend" {
  for_each    = var.frontend_team
  name        = each.key
  description = "Frontend user: ${each.key}"
  account_ids = [boundary_account.frontend_user_acct[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_user" "leadership" {
  for_each    = var.leadership_team
  name        = each.key
  description = "WARNING: Managers should be read-only"
  account_ids = [boundary_account.leadership_user_acct[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_account" "backend_user_acct" {
  for_each       = var.backend_team
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "foofoofoo"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account" "frontend_user_acct" {
  for_each       = var.frontend_team
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "foofoofoo"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account" "leadership_user_acct" {
  for_each       = var.leadership_team
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "foofoofoo"
  auth_method_id = boundary_auth_method.password.id
}

// organiation level group for the leadership team
resource "boundary_group" "leadership" {
  name        = "leadership_team"
  description = "Organization group for leadership team"
  member_ids  = [for user in boundary_user.leadership : user.id]
  scope_id    = boundary_scope.org.id
}

// project level group for backend and frontend management of core infra
resource "boundary_group" "backend_core_infra" {
  name        = "backend"
  description = "Backend team group"
  member_ids  = [for user in boundary_user.backend : user.id]
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_group" "frontend_core_infra" {
  name        = "frontend"
  description = "Frontend team group"
  member_ids  = [for user in boundary_user.frontend : user.id]
  scope_id    = boundary_scope.core_infra.id
}
