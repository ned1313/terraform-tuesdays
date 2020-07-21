variable "my_str" {
    type = string

    validation {
        condition = length(var.my_str) > 3
        error_message = "String must be over 3 characters in length."
    }
    default = "my-string"
}

output "my_str" {
    value = var.my_str
}