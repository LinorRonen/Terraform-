provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/terraform-ec2-key.pem"
  file_permission = "0600"  
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "ubuntu_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.ssh_access.name]

  tags = {
    Name = "Ubuntu-Server"
  }
}

output "ec2_public_ip" {
  value       = aws_instance.ubuntu_server.public_ip
  description = "Public IP of the EC2 instance"
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the private key file"
}
