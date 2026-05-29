# for ansible
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

#SG GROUPS
resource "aws_security_group" "bastion" {
  name   = "${var.project_name}-bastion-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_security_group" "jenkins" {
  name   = "${var.project_name}-jenkins-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "jenkins_slave" {
  name   = "${var.project_name}-jenkins-slave-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-jenkins-slave-sg"
  }
}

# INGRESS RULES
resource "aws_vpc_security_group_ingress_rule" "bastion_in" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh" {
  security_group_id            = aws_security_group.jenkins.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_in" {
  security_group_id            = aws_security_group.jenkins.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "slave_ssh_from_master" {
  security_group_id            = aws_security_group.jenkins_slave.id
  referenced_security_group_id = aws_security_group.jenkins.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

# EGRESS RULES
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  for_each = {
    bastion       = aws_security_group.bastion.id
    jenkins       = aws_security_group.jenkins.id
    alb           = aws_security_group.alb.id
    jenkins_slave = aws_security_group.jenkins_slave.id
  }
  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
