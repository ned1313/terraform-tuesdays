variable "session_name" {}
variable "speaker_name" {}
variable "shirt" {}
variable "mug" {
  type = bool
}
variable "dog" {
  type = bool
}

resource "local_file" "main" {
  filename = "sessions.txt"
  content  = <<EOF
Session Name: ${var.session_name}
Speaker Name: ${var.speaker_name}
Shirt: ${var.shirt}
Mug: ${var.mug}
Dog: ${var.dog}
EOF
}