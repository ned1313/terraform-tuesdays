# Let's checkout this variable syntax
variable "no_caps" {
    type = string

    validation {
        condition = lower(var.no_caps) == var.no_caps
        error_message = "Value must be in all lower case."
    }

}

variable "always_wrong" {
    type = string

    validation {
        condition = length(var.always_wrong) == length(var.always_wrong)
        error_message = "You'll never get this right."
    }
}


variable "ip_address" {
    type = string

    validation {
        condition = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
        error_message = "Must be an IP address of the form X.X.X.X."
    }
}


module "default_variable" {
    source = "./mock_mod"

    my_str = var.no_caps
    
}


output "ip_address" {
    value = var.ip_address
}

output "no_caps" {
    value = var.no_caps
}