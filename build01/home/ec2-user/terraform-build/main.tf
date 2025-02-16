provider "aws" {
  region = "eu-west-2"
}

# Automatically get the instance ID of the server running Terraform
data "aws_instance" "terraform_host" {
  filter {
    name   = "instance-id"
    values = [chomp(file("/var/lib/cloud/data/instance-id"))]
  }
}

# Retrieve the subnet of the Terraform host
data "aws_subnet" "terraform_subnet" {
  id = data.aws_instance.terraform_host.subnet_id
}

# Create a new EC2 instance in the same subnet as the Terraform host
resource "aws_instance" "host01" {
  ami           = "ami-0c76bd4bd302b30ec"
  instance_type = "t2.nano"
  subnet_id     = data.aws_subnet.terraform_subnet.id
  private_ip    = "10.0.1.11"

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname host01
    mkdir -p /home/ec2-user/.ssh
    chmod 700 /home/ec2-user/.ssh
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0e3/SJ2Ylwhke7R9Z3dw0SDP8gHYoXwDmqvk1vIbuV Fuji02HostKey" > /
home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
    cat <<EOF2 > /home/ec2-user/ssh-key
    -----BEGIN OPENSSH PRIVATE KEY-----
    REDACTED
    -----END OPENSSH PRIVATE KEY-----
    EOF2
    chmod 600 /home/ec2-user/ssh-key
    chown ec2-user:ec2-user /home/ec2-user/ssh-key
    chown -R ec2-user:ec2-user /home/ec2-user/.ssh
  EOF

  tags = {
    Name = "host01"
  }
}

