variable "protein" {
  type = string

  validation {
      condition = contains(["chicken","beef","tofu"],lower(var.protein))
      error_message = "The protein must be in the approved list of proteins."
  }

  validation {
      condition = lower(var.protein) == var.protein
      error_message = "The protein name must not have capital letters."
  }
}
