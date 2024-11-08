resource "local_file" "count_int_loop" {
  count = 3
  content = "This is file number ${count.index}"
  filename = "${path.module}/int-${count.index}.count"
}

output "contents" {
  value = [for f in local_file.count_int_loop : f.content]
}

data "terraform_remote_state" "remote" {
  backend = "remote"

  config = {
    organization = "my-org"
    workspaces = {
      name = "that-workspace"
    }
  }
}

data "tfe_outputs" "remote" {
  organization = "my-org"
  workspace = "that-workspace"
}