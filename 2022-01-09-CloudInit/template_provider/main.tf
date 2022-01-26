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

/*
resource "local_file" "cloud_init_gzip" {
  filename    = "cloud_init_gzip.tgz"
  content = data.template_cloudinit_config.config_gzip.rendered
}
*/