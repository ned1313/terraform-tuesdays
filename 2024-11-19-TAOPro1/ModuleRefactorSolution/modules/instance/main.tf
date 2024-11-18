resource "aws_security_group" "allow_http" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = {
    Name = var.instance_name
  }
}