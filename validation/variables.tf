
variable "vm_size" {
    description = "Size of VM to use. Must be D or E series and between 4 and 12 CPUs."
    type = string
    
    validation {
        condition = can(regex("^Standard_[DE].*", var.vm_size))
        error_message = "Variable vm_size must be D or E series with 4-12 CPUs. Value provided was ${var.vm_size}"
    }
    
}