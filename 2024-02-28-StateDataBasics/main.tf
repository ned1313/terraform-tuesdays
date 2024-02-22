resource "local_file" "test" {
  for_each = toset(["a", "b"])

  content = each.key
  filename = "${path.root}/files/${each.key}.txt"
}

provider "local" {
  alias = "alt"
}

resource "local_file" "alt" {
  for_each = toset(["c", "d"])
  provider = local.alt

  content = each.key
  filename = "${path.root}/files/${each.key}.txt"
}

module "files" {
  count  = 2
  source = "./file-creator"

  content  = "Hi! My name is ${count.index}"
  filename = "${path.root}/files/my_file_${count.index}.txt"
}

module "files_foreach" {
  source = "./file-creator"

  for_each = {
    arthur         = "dent"
    tricia         = "mcmillian"
  }

  content  = each.value
  filename = "${path.root}/files/${each.key}.txt"

}

output "names" {
  value = module.files[*].stuff
}