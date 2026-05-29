provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = "vdavl"
      ManagedBy   = "Terraform"
    }
  }
}

#AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "aws-task6-eks"
    key    = "dev/terraform.tfstate"
    region = "us-east-2"
  }
}

# Jenkins-slave
resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.jenkins_slave_sg_id]
  key_name               = data.terraform_remote_state.vpc.outputs.key_name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "${var.project_name}-jenkins-slave"
    Role = "jenkins-slave"
  }
}
