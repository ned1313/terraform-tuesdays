# We'll create a cloud-init multiple MIME using a data source for all pieces.
data "template_file" "cloud_init" {
  template = file("cloud-init.yaml")

  vars = {
    package_update  = "true"
    package_upgrade = "false"
  }
}

data "template_file" "x_shellscript" {
  template = file("startup-script.sh")
  vars = {
    name = "Arthur"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.x_shellscript.rendered
  }
}

data "template_cloudinit_config" "config_gzip" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.x_shellscript.rendered
  }
}

resource "local_file" "cloud_init_plaintext" {
  filename    = "cloud_init_plaintext.txt"
  content = data.template_cloudinit_config.config.rendered
}

resource "local_file" "cloud_init_gzip" {
  filename    = "cloud_init_gzip.tgz"
  content = data.template_cloudinit_config.config_gzip.rendered
}

locals {
    cloud_init_parts = {
        cloud-init = {
            filepath = "cloud-init.yaml"
            content-type = "text/cloud-config"
            vars = {
                package_update  = "true"
                package_upgrade = "false"
            }
        },
        x-shellscript = {
            filepath = "startup-script.sh"
            content-type = "text/x-shellscript"
            vars = {
                name = "Arthur"
            }
        }
    }

    cloud_init_parts_rendered = [ for k,v in local.cloud_init_parts : <<EOF
--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: ${v.content-type}
Mime-Version: 1.0

${templatefile(v.filepath, v.vars)}
    EOF
    ]

    cloud_init_complete = templatefile("cloud-init.tpl", {cloud_init_parts = local.cloud_init_parts_rendered})
}

resource "local_file" "cloud_init_from_locals" {
  filename    = "cloud_init_from_locals.txt"
  content = local.cloud_init_complete
}