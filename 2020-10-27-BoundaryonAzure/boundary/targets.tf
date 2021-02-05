resource "boundary_target" "backend_servers_ssh" {
  type                     = "tcp"
  name                     = "backend_servers_ssh"
  description              = "Backend SSH target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 22
  host_set_ids = [
    boundary_host_set.backend_servers.id
  ]
}

resource "boundary_target" "backend_servers_website" {
  type                     = "tcp"
  name                     = "backend_servers_website"
  description              = "Backend website target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 8000
  host_set_ids = [
    boundary_host_set.backend_servers.id
  ]
}
