output "jenkins_url" {
  value = "https://jenkins.${var.domain_name}"
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "key_name" {
  value = aws_key_pair.task6_key.key_name
}

output "jenkins_slave_sg_id" {
  value = aws_security_group.jenkins_slave.id
}