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

    cloud_init_gzip = base64gzip(templatefile("cloud-init.tpl", {cloud_init_parts = local.cloud_init_parts_rendered}))
}

/*
resource "local_file" "cloud_init_from_locals" {
  filename    = "cloud_init_from_locals.zip"
  content = local.cloud_init_complete
}
*/