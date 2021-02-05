variable "my_str" {
    type = string

    default = "my-string"
}

variable "complex_object" {
    type = list(object({
        name = string
        start_port = number
        end_port = number
        protocol = string
    }))

    default = [
        {
            name = "http"
            start_port = 80
            end_port = 80
            protocol = "tcp"
        }
    ]
}

output "complex_output" {
    value = var.complex_object
}