#AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Bastion
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.task6_key.key_name
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
}

# Jenkins
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.task6_key.key_name
  subnet_id              = values(aws_subnet.private)[0].id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}

#key
resource "aws_key_pair" "task6_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/task6_key.pub")
}

#ssh config
resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/../ansible/ssh_config.tpl", {
    jenkins_ip = aws_instance.jenkins.private_ip
    bastion_ip = aws_eip.bastion.public_ip
  })

  filename = "${path.module}/../ansible/ssh_config"
}
