output "controller_template" {
    value = data.template_file.controller.rendered
}

output "worker_template" {
    value = data.template_file.worker.rendered
}