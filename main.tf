terraform {
  backend "s3" {
    bucket = "devopsdurgajob"
    key    = "backend/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "my_server" {
  instance_type        = "t2.micro"
  ami                  = "ami-051de6a4e7ae45f77"
  key_name             = "durga"
  availability_zone    = "us-east-2b"
  hibernation          = true

  root_block_device {
    encrypted   = true
    volume_size = 10
  }

  tags = {
    Name = "naaistam"
  }

  ebs_block_device {
    device_name             = "/dev/sdb"
    volume_size             = 8
    encrypted               = true
    delete_on_termination   = true
  }

  provisioner "local-exec" {
    command = <<EOT
       sleep 120
       ssh-keygen -R ${self.public_ip}
       
      sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${self.public_ip}, playbook.yaml -u ec2-user --private-key /root/ansible/.ssh/mykey.pem 
    EOT
  }
}

output "aws_attributes" {
  value = aws_instance.my_server
}
