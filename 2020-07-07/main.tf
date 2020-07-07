locals {
    rules = [
        {
            name = "https"
            start_port = 443
            end_port = 443
            protocol = "tcp"
        },
        {
            name = "udp"
            start_port = -1
            end_port = -1
            protocol = "udp"
        }
    ]
}

module "default_variable" {
    source = "./mock_mod"
    
}

module "local_variable" {
    source = "./mock_mod"

    complex_object = local.rules
    
}

output "default_variable" {
    value = module.default_variable.complex_output
}